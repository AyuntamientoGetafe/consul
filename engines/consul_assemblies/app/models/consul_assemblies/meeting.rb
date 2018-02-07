module ConsulAssemblies
  class Meeting < ActiveRecord::Base
    include Flaggable
    include Taggable
    include Sanitizable
    include Followable
    include ConsulAssemblies::Concerns::Notificable


    VALID_STATUSES = %w{open closed}

    belongs_to :assembly
    belongs_to :user
    has_many :attachments, as: :attachable
    has_many :proposals
    has_many :comments, as: :commentable

    after_save :notify_to_followers

    validate :published_at_must_be_before_scheduled_at
    validates :assembly, presence: true, associated: true
    validates :description, presence: true
    validates :user, presence: true

    mount_uploader :attachment, AttachmentUploader


    accepts_nested_attributes_for :attachments,  :reject_if => :all_blank, :allow_destroy => true

    scope :published, -> { where('published_at <= ?', Time.current)}
    scope :without_held, -> { where('scheduled_at >= ?', Time.current)}
    scope :order_by_scheduled_at,  -> { order(scheduled_at: 'desc') }
    scope :with_hidden,  -> { order(scheduled_at: 'desc') }

    def ready_for_held?
      Time.current >= close_accepting_proposals_at  && Time.current < scheduled_at
    end

    def author
      user
    end

    def author_id
      user_id
    end

    def accepting_proposals?
      Time.current < close_accepting_proposals_at
    end

    def held?
      Time.current > scheduled_at
    end

    def published_at_must_be_before_scheduled_at
      errors.add(:published_at, 'no puede estar antes que la fecha programada') if published_at > scheduled_at
    end


    def archived?
      false
    end

    def comments_count
      0
    end
  end
end