class Hero < ApplicationRecord
  self.table_name = "heroes"
  
  ROLES = ['Tank', 'Fighter', 'Assassin', 'Mage', 'Marksman', 'Support'].freeze
  has_one_attached :image
end