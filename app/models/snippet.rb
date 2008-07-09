class Snippet < ActiveRecord::Base
  # Class Attributes
  cattr_accessor :per_page
  @@per_page = 10

  # Attributes
  attr_protected :user_id
  attr_protected :formatted_body

  # Plugins
  define_index do
    indexes :body
    indexes language.name, :as => :name
  end

  # Relationships
  belongs_to :language, :counter_cache => true

  # Validations
  validates_length_of :body, :minimum => 1
  validates_presence_of :language_id

  # Scopes
  named_scope :language, lambda{ |language_id| { :conditions => language_id.blank? ? nil : { :language_id => language_id } } }

  # Callbacks
  before_save :format_body
  before_save :format_preview

  def format_body
    self.formatted_body = Uv.parse(self.body, "xhtml", self.language.slug, false, "clean")
  end

  def format_preview
    self.formatted_preview = Uv.parse(self.preview, "xhtml", self.language.slug, false, "clean")
  end

  def preview
    self.body.split("\n")[0..4].join("\n")
  end
end