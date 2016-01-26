class DevelopmentSerializer

  def initialize(record, options={})
    @record  = record
    @options = options
  end

  def to_row
    [attributes.values.map { |value| ensure_csv_ready(value) },
      DevelopmentTeamSerializer.new(@record, max_team_size).to_row].flatten
  rescue
    []
  end

  def to_header
    [attributes.keys,
      DevelopmentTeamSerializer.new(@record, max_team_size).to_header].flatten
  rescue
    []
  end

  private

    def attributes
      return only_attributes   if only?
      return except_attributes if except?
      @record.attributes
    end

    def only?
      @options.fetch(:only, false)
    end

    def except?
      @options.fetch(:except, false)
    end

    def only_attributes
      @record.attributes.select{|k,_v| only_selection.include? k.to_sym }
    end

    def except_attributes
      @record.attributes.reject{|k,_v| except_selection.include? k.to_sym }
    end

    def only_selection
      selection :only
    end

    def except_selection
      selection :except
    end

    def selection(option)
      option = option.to_sym
      Array(@options[option]).flatten.map(&:to_sym)
    end

    def max_team_size
      @options.fetch(:max_team_size) { 1 }
    end

    def ensure_csv_ready(attribute)
      if attribute.class.to_s.include? 'Time'
        attribute.to_s
      else
        attribute
      end
    end

end