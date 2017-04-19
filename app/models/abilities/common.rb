module Abilities
  class Common
    include CanCan::Ability

    def initialize(user)
      self.merge Abilities::Everyone.new(user)

      can [:read, :update], User, id: user.id

      can :read, Debate
      can :update, Debate do |debate|
        debate.editable_by?(user)
      end
      cannot :update, Debate # GET-53

      can :read, Proposal
      can :update, Proposal do |proposal|
        proposal.editable_by?(user)
      end
      can [:retire_form, :retire], Proposal, author_id: user.id

      can :read, SpendingProposal

      #GET-53
      cannot :create, Comment
      cannot :create, Debate
      cannot :create, Proposal
      cannot :suggest, Debate

      can :suggest, Proposal

      can [:flag, :unflag], Comment
      cannot [:flag, :unflag], Comment, user_id: user.id

      can [:flag, :unflag], Debate
      cannot [:flag, :unflag], Debate, author_id: user.id

      can [:flag, :unflag], Proposal
      cannot [:flag, :unflag], Proposal, author_id: user.id

      unless user.organization?
        can :vote, Debate
        can :vote, Comment
      end

      cannot :vote, Comment do |comment|
        comment.commentable.try(:likes_disallowed?)
      end

      if user.level_two_or_three_verified?
        can :vote, Proposal
        can :vote_featured, Proposal
        can :vote, SpendingProposal
        can :create, SpendingProposal

        can :create, Budget::Investment,               budget: { phase: "accepting" }
        can :vote,   Budget::Investment,               budget: { phase: "accepting" } #GET-65
        can [:show, :create], Budget::Ballot,          budget: { phase: "balloting" }
        can [:create, :destroy], Budget::Ballot::Line, budget: { phase: "balloting" }

        can :create, DirectMessage
        can :show, DirectMessage, sender_id: user.id
        can :create, Comment
      end

      can [:create, :show], ProposalNotification, proposal: { author_id: user.id }

      can :create, Annotation
      can [:update, :destroy], Annotation, user_id: user.id
    end
  end
end
