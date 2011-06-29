class SneakPollsController < ApplicationController
  unloadable

  before_filter :set_project
  before_filter :authorize
  before_filter :set_sneak_polls, :only => :index
  before_filter :set_sneak_poll, :only => [:show, :stats, :edit, :destroy, :vote]

  helper :sort
  include SortHelper

  def index
    sort_init 'created_at'
    sort_update %w(title created_at votes_count average_timeliness average_quality average_commitment average_office_procedures average_grade)

    #TODO: -> Model
    if @sort_criteria.first_key
      @sneak_polls.sort! do |p1, p2|
        dir = @sort_criteria.first_asc? ? 1 : -1
        a = p1.send(@sort_criteria.first_key.to_sym)
        b = p2.send(@sort_criteria.first_key.to_sym)
        a && b ? dir * (a <=> b) : (a.nil? && b.nil? ? 0 : (a.nil? ? 1 : -1))
      end
    end

    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @votes  = @sneak_poll.votes.by_voter(User.current).exclude_user(User.current).all(:include => [:poll, :user, :voter])
    @votes += @project.users.reject{|user| (user == User.current) || @votes.map(&:user).include?(user)}.map{|user| @sneak_poll.votes.build{|vote| vote.voter = User.current; vote.user = user}}
    @votes.sort_by(&:user)
  end

  def stats
    sort_init 'users.lastname'
    sort_update %w(users.lastname average_timeliness average_quality average_commitment average_office_procedures)

    @principal_stats = @sneak_poll.votes.by_principals.select_stats.all(:include => :user).group_by(&:user)
    @coworker_stats = @sneak_poll.votes.exclude_principals.select_stats.all(:include => :user).group_by(&:user)
    @users = (@principal_stats.keys + @coworker_stats.keys).uniq
  end

  def new
    @sneak_poll = @project.sneak_polls.build(params[:sneak_poll])

    if request.post? && @sneak_poll.save
      flash[:notice] = t(:notice_successful_create)

      redirect_to :controller => 'sneak_polls', :action => 'show', :project_id => @project, :id => @sneak_poll, :tab => 'sneak-polls'
    end
  end

  def edit
    if request.post? && @sneak_poll.update_attributes(params[:sneak_poll])
      redirect_to :controller => 'sneak_polls', :action => 'show', :project_id => @project, :id => @sneak_poll, :tab => 'sneak-polls'
    end
  end

  def destroy
    @sneak_poll.destroy

    redirect_to :controller => 'sneak_polls', :project_id => @project, :tab => 'sneak-polls'
  end

  def vote
    SneakPollVote.transaction do
      @votes = SneakPollVote.all_unique_from_params(@sneak_poll, User.current, params[:vote])

      @votes.reject!{|vote| vote.new_record? && vote.blank?}        # Ignore new blank votes
      @votes.reject(&:new_record?).select(&:blank?).each(&:destroy) # Destroy existing blank votes
      @votes.reject(&:blank?).each(&:save)                          # Create or update non-blank votes
    end

    if @votes.detect(&:invalid?)
      flash.now[:error] = t(:text_sneak_poll_vote_error)
      render :action => 'show'
    else
      flash[:notice] = t(:text_sneak_poll_voted, :sneak_poll => @sneak_poll.title)
      redirect_to :controller => 'sneak_polls', :action => 'show', :project_id => @project, :id => @sneak_poll, :tab => 'sneak-polls'
    end
  end

  private ##############################################################################################################

  def set_project
    @project = Project.find(params[:project_id], :include => [:users, :versions])
  end

  def set_sneak_polls
    @sneak_polls = @project.sneak_polls.order.all
  end

  def set_sneak_poll
    @sneak_poll = @project.sneak_polls.find(params[:id])
  end

end
