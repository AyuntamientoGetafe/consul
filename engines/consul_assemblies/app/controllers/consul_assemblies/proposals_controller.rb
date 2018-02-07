require_dependency "consul_assemblies/application_controller"

module ConsulAssemblies
  class ProposalsController < ApplicationController

    before_action :authenticate_user!, except: [:index, :show]
    before_filter :load_meeting, only: [:new]
    load_and_authorize_resource :proposal, through: :meeting, class: "ConsulAssemblies::Meeting"

    def index; end

    def create

      @proposal = ConsulAssemblies::Proposal.new(proposal_params.merge({ user: current_user }))
      if @proposal.save
        redirect_to @proposal.meeting
      else
        @meeting = @proposal.meeting
        render action: :new
      end
    end


    private

    def proposal_params
      params.require(:proposal).permit(
        :title,
        :description,
        :meeting_id,
        :assembly_id
      )
    end

    def load_meeting
      @meeting =  ConsulAssemblies::Meeting.find(params[:meeting_id])
    end
  end
end