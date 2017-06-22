class Admin::BudgetsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  has_filters %w{current finished}, only: :index

  load_and_authorize_resource

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
    @budget = Budget.includes(groups: :headings).find(params[:id])
  end

  def new
  end

  def edit
  end

  #GET-112
  def results
    if params[:group_id]
      @group = @budget.groups.find(params[:group_id])
    else
      @group = @budget.groups.first if @budget.groups.any?
    end
  end

  #GET-130
  def ballot_dashboard
    @ballots = @budget.ballots.where.not(user_id: nil).joins(:user).where('users.verified_at IS NOT NULL').order('created_at desc')
    @confirmations = Budget::Ballot::Confirmation.where(budget: @budget, discarted_at: nil)
    @confirmations_verified = Budget::Ballot::Confirmation.where(budget: @budget, discarted_at: nil).where.not(confirmed_at: nil)
  end

  #GET-112
  def ballot_paper
    if params[:group_id]
      @group = @budget.groups.find(params[:group_id])
    else
      @group = @budget.groups.first if @budget.groups.any?
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to admin_budget_path(@budget), notice: t('admin.budgets.update.notice')
    else
      render :edit
    end
  end

  def create
    @budget = Budget.new(budget_params)
    if @budget.save
      redirect_to admin_budget_path(@budget), notice: t('admin.budgets.create.notice')
    else
      render :new
    end
  end

  private

    def budget_params
      descriptions = Budget::PHASES.map{|p| "description_#{p}"}.map(&:to_sym)
      valid_attributes = [:name, :phase, :currency_symbol] + descriptions
      params.require(:budget).permit(*valid_attributes)
    end

end
