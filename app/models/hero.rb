class Hero < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :role, presence: true
  validates :specialty, presence: true
  validates :difficulty, presence: true, inclusion: { in: 1..10 }
  validates :lane, presence: true
  validates :description, presence: true, length: { minimum: 10 }

  ROLES = ['Tank', 'Fighter', 'Assassin', 'Mage', 'Marksman', 'Support'].freeze
  LANES = ['Exp Lane', 'Jungle', 'Mid Lane', 'Gold Lane', 'Roam'].freeze
  SPECIALTIES = ['Charge', 'Regen', 'Burst', 'Poke', 'Push', 'Support'].freeze

  validates :role, inclusion: { in: ROLES }
  validates :lane, inclusion: { in: LANES }
  validates :specialty, inclusion: { in: SPECIALTIES }
end
