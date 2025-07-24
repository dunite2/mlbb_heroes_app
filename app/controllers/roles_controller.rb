class RolesController < ApplicationController
  def index
    @roles = Hero::ROLES
    @heroes_by_role = Hero.all.group_by(&:role)
  end
end
