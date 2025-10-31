class TeamForm
  include ActiveModel::Model

  attr_accessor :name

  validates :name, 
    presence: { message: " can't be blank." },
    length: { maximum: 50, message: " must be less than 50 characters." }

  def initialize(params = {}, team = nil)
    @team = team || Team.new
    
    load_team_attributes if team&.persisted?
    super(params)
  end

  def attributes
    {
      'name'     => name,
    }.stringify_keys
  end

  def save
    return false unless valid?

    @team = Team.new(attributes)

    if @team.save
      true
    else
      copy_errors_from_team
      false
    end
  end

  def update
    return false unless valid? 

    if @team.update(attributes)
      true
    else
      copy_errors_from_team
      false
    end
  end

  def load_team_attributes
    self.name = @team.name
  end

  attr_reader :team

  private

  def copy_errors_from_team
    @team.errors.each do |error|
      self.errors.add(error.attribute, error.message)
    end
  end
end
