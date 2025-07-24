class MlbbApiService
  include HTTParty
  base_uri 'https://mlbb-stats.ridwaanhall.com/api'
  
  def self.fetch_heroes
    # Request JSON format explicitly and set proper headers
    options = {
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    }
    
    response = get('/hero-list/?format=json', options)
    
    if response.success?
      data = response.parsed_response
      # Handle different response structures
      if data.is_a?(Hash) && data['results']
        data['results']
      elsif data.is_a?(Array)
        data
      else
        []
      end
    else
      Rails.logger.error "MLBB API Error: #{response.code} - #{response.message}"
      []
    end
  rescue StandardError => e
    Rails.logger.error "MLBB API Service Error: #{e.message}"
    []
  end

  def self.import_heroes_to_database
    heroes_data = fetch_heroes
    Rails.logger.info "Fetched #{heroes_data.length} heroes from API"
    
    # If API doesn't return data, use sample data for demonstration
    if heroes_data.empty?
      Rails.logger.info "API returned no data, using sample heroes"
      heroes_data = sample_heroes_data
    end
    
    return 0 if heroes_data.empty?
    
    imported_count = 0

    heroes_data.each do |hero_data|
      Rails.logger.debug "Processing hero: #{hero_data.inspect}"
      
      # Map API data to our Hero model attributes
      hero_attributes = {
        name: hero_data['name'] || hero_data[:name],
        role: map_role(hero_data['role'] || hero_data[:role]),
        specialty: map_specialty(hero_data['specialty'] || hero_data[:specialty]),
        difficulty: (hero_data['difficulty'] || hero_data[:difficulty] || 5).to_i,
        lane: map_lane(hero_data['lane'] || hero_data[:lane]),
        description: hero_data['description'] || hero_data[:description] || "A powerful #{hero_data['role'] || hero_data[:role]} hero from Mobile Legends.",
        image_url: hero_data['image_url'] || hero_data[:image_url] || "https://via.placeholder.com/200x280/1e3a8a/ffffff?text=#{(hero_data['name'] || hero_data[:name] || 'Hero').gsub(' ', '+')}"
      }

      # Skip if no name
      next unless hero_attributes[:name].present?

      # Create or update hero
      hero = Hero.find_or_initialize_by(name: hero_attributes[:name])
      hero.assign_attributes(hero_attributes)
      
      if hero.save
        imported_count += 1
        Rails.logger.info "Saved hero: #{hero.name}"
      else
        Rails.logger.warn "Failed to save hero: #{hero_attributes[:name]} - #{hero.errors.full_messages}"
      end
    end

    Rails.logger.info "Successfully imported #{imported_count} heroes"
    imported_count
  rescue StandardError => e
    Rails.logger.error "Import error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end

  # Sample data for demonstration when API is not available
  def self.sample_heroes_data
    [
      {
        'name' => 'Alucard',
        'role' => 'Fighter',
        'specialty' => 'Charge',
        'difficulty' => 3,
        'lane' => 'Exp Lane',
        'description' => 'A demon hunter with incredible lifesteal abilities.',
        'image_url' => 'https://images.ixigo.com/image/upload/f_auto,q_auto,w_400,h_400/misc/1579586655_alucard.png'
      },
      {
        'name' => 'Miya',
        'role' => 'Marksman',
        'specialty' => 'Push',
        'difficulty' => 2,
        'lane' => 'Gold Lane',
        'description' => 'An elven archer with powerful area damage capabilities.',
        'image_url' => 'https://images.ixigo.com/image/upload/f_auto,q_auto,w_400,h_400/misc/1579586655_miya.png'
      },
      {
        'name' => 'Tigreal',
        'role' => 'Tank',
        'specialty' => 'Support',
        'difficulty' => 4,
        'lane' => 'Roam',
        'description' => 'A stalwart tank with powerful crowd control abilities.',
        'image_url' => 'https://i.imgur.com/5K7zJ4a.png'
      },
      {
        'name' => 'Gusion',
        'role' => 'Assassin',
        'specialty' => 'Burst',
        'difficulty' => 8,
        'lane' => 'Jungle',
        'description' => 'A magical assassin with deadly combo potential.',
        'image_url' => 'https://i.imgur.com/8B9wX2c.png'
      },
      {
        'name' => 'Kagura',
        'role' => 'Mage',
        'specialty' => 'Burst',
        'difficulty' => 7,
        'lane' => 'Mid Lane',
        'description' => 'An onmyoji master with umbrella-based magic attacks.',
        'image_url' => 'https://i.imgur.com/4K8yM3p.png'
      },
      {
        'name' => 'Angela',
        'role' => 'Support',
        'specialty' => 'Support',
        'difficulty' => 5,
        'lane' => 'Roam',
        'description' => 'A puppet master who can possess allies to provide support.',
        'image_url' => 'https://i.imgur.com/7N2qR5t.png'
      },
      {
        'name' => 'Granger',
        'role' => 'Marksman',
        'specialty' => 'Burst',
        'difficulty' => 6,
        'lane' => 'Gold Lane',
        'description' => 'A violinist marksman with rhythmic burst damage.',
        'image_url' => 'https://i.imgur.com/9P4vL6w.png'
      },
      {
        'name' => 'Esmeralda',
        'role' => 'Tank',
        'specialty' => 'Regen',
        'difficulty' => 5,
        'lane' => 'Exp Lane',
        'description' => 'A shield-stealing tank with magical abilities.',
        'image_url' => 'https://i.imgur.com/3H5yQ8n.png'
      },
      {
        'name' => 'Lunox',
        'role' => 'Mage',
        'specialty' => 'Burst',
        'difficulty' => 6,
        'lane' => 'Mid Lane',
        'description' => 'A twilight goddess with light and dark powers.',
        'image_url' => 'https://i.imgur.com/6K9rM4p.png'
      },
      {
        'name' => 'Aldous',
        'role' => 'Fighter',
        'specialty' => 'Charge',
        'difficulty' => 4,
        'lane' => 'Exp Lane',
        'description' => 'A contract holder with soul-stealing abilities.',
        'image_url' => 'https://i.imgur.com/2L7qX9w.png'
      },
      {
        'name' => 'Lesley',
        'role' => 'Marksman',
        'specialty' => 'Poke',
        'difficulty' => 5,
        'lane' => 'Gold Lane',
        'description' => 'A sniper with deadly long-range precision.',
        'image_url' => 'https://i.imgur.com/8M3vN5r.png'
      },
      {
        'name' => 'Kaja',
        'role' => 'Support',
        'specialty' => 'Support',
        'difficulty' => 3,
        'lane' => 'Roam',
        'description' => 'A lightning manipulator with crowd control abilities.',
        'image_url' => 'https://i.imgur.com/4P9qW2t.png'
      },
      {
        'name' => 'Hanzo',
        'role' => 'Assassin',
        'specialty' => 'Poke',
        'difficulty' => 7,
        'lane' => 'Jungle',
        'description' => 'A ninja with demonic possession abilities.',
        'image_url' => 'https://i.imgur.com/7X4yL8n.png'
      },
      {
        'name' => 'Kadita',
        'role' => 'Mage',
        'specialty' => 'Burst',
        'difficulty' => 5,
        'lane' => 'Mid Lane',
        'description' => 'A sea goddess with powerful water magic.',
        'image_url' => 'https://i.imgur.com/5Q8rM3p.png'
      },
      {
        'name' => 'Claude',
        'role' => 'Marksman',
        'specialty' => 'Push',
        'difficulty' => 4,
        'lane' => 'Gold Lane',
        'description' => 'A thief with a magical monkey companion.',
        'image_url' => 'https://i.imgur.com/9K6vN4w.png'
      },
      {
        'name' => 'Khufra',
        'role' => 'Tank',
        'specialty' => 'Support',
        'difficulty' => 6,
        'lane' => 'Roam',
        'description' => 'An ancient pharaoh with powerful crowd control.',
        'image_url' => 'https://i.imgur.com/3H8qL5r.png'
      },
      {
        'name' => 'Harith',
        'role' => 'Mage',
        'specialty' => 'Burst',
        'difficulty' => 6,
        'lane' => 'Mid Lane',
        'description' => 'A time manipulator with incredible mobility.',
        'image_url' => 'https://i.imgur.com/6P2yM7t.png'
      },
      {
        'name' => 'Kimmy',
        'role' => 'Marksman',
        'specialty' => 'Poke',
        'difficulty' => 7,
        'lane' => 'Gold Lane',
        'description' => 'A cyborg with energy cannon abilities.',
        'image_url' => 'https://i.imgur.com/8L4vX9w.png'
      },
      {
        'name' => 'Thamuz',
        'role' => 'Fighter',
        'specialty' => 'Regen',
        'difficulty' => 5,
        'lane' => 'Exp Lane',
        'description' => 'A lord of the abyss with scythe mastery.',
        'image_url' => 'https://i.imgur.com/4M9qN2p.png'
      },
      {
        'name' => 'Selena',
        'role' => 'Assassin',
        'specialty' => 'Burst',
        'difficulty' => 8,
        'lane' => 'Jungle',
        'description' => 'A dark elf with dual form abilities.',
        'image_url' => 'https://i.imgur.com/7K5yL3r.png'
      },
      {
        'name' => 'Faramis',
        'role' => 'Support',
        'specialty' => 'Support',
        'difficulty' => 4,
        'lane' => 'Roam',
        'description' => 'A necromancer with resurrection abilities.',
        'image_url' => 'https://i.imgur.com/5Q8wM6t.png'
      },
      {
        'name' => 'Badang',
        'role' => 'Fighter',
        'specialty' => 'Charge',
        'difficulty' => 3,
        'lane' => 'Exp Lane',
        'description' => 'A martial artist with fist-based combat.',
        'image_url' => 'https://i.imgur.com/3N7qX4p.png'
      },
      {
        'name' => 'Guinevere',
        'role' => 'Fighter',
        'specialty' => 'Burst',
        'difficulty' => 6,
        'lane' => 'Exp Lane',
        'description' => 'A noble fighter with magic-enhanced combat.',
        'image_url' => 'https://i.imgur.com/9P5yL8w.png'
      },
      {
        'name' => 'Valir',
        'role' => 'Mage',
        'specialty' => 'Burst',
        'difficulty' => 4,
        'lane' => 'Mid Lane',
        'description' => 'A flame wielder with area control abilities.',
        'image_url' => 'https://i.imgur.com/6K2qM5r.png'
      },
      {
        'name' => 'Chang\'e',
        'role' => 'Mage',
        'specialty' => 'Poke',
        'difficulty' => 3,
        'lane' => 'Mid Lane',
        'description' => 'A moon goddess with lunar magic.',
        'image_url' => 'https://i.imgur.com/4L8vN7t.png'
      }
    ]
  end

  private

  def self.map_role(api_role)
    # Map API roles to our defined roles
    case api_role&.downcase
    when 'tank' then 'Tank'
    when 'fighter' then 'Fighter'
    when 'assassin' then 'Assassin'
    when 'mage' then 'Mage'
    when 'marksman', 'mm' then 'Marksman'
    when 'support' then 'Support'
    else 'Fighter' # default
    end
  end

  def self.map_specialty(api_specialty)
    # Map API specialties to our defined specialties
    case api_specialty&.downcase
    when 'charge' then 'Charge'
    when 'regen' then 'Regen'
    when 'burst' then 'Burst'
    when 'poke' then 'Poke'
    when 'push' then 'Push'
    when 'support' then 'Support'
    else 'Burst' # default
    end
  end

  def self.map_lane(api_lane)
    # Map API lanes to our defined lanes
    case api_lane&.downcase
    when 'exp', 'exp lane' then 'Exp Lane'
    when 'jungle' then 'Jungle'
    when 'mid', 'mid lane' then 'Mid Lane'
    when 'gold', 'gold lane' then 'Gold Lane'
    when 'roam' then 'Roam'
    else 'Mid Lane' # default
    end
  end
end
