class HeroesController < ApplicationController
  before_action :set_hero, only: [:show, :edit, :update, :destroy]

  def index
    @heroes = Hero.all

    if params[:search].present?
      search_term = params[:search].downcase
      @heroes = @heroes.where(
        "LOWER(name) LIKE ? OR LOWER(role) LIKE ? OR LOWER(specialty) LIKE ? OR LOWER(lane) LIKE ? OR LOWER(description) LIKE ?",
        "%#{search_term}%", "%#{search_term}%", "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"
      )
    end
    @heroes = @heroes.order(:name)


    @heroes_by_role = @heroes.group_by(&:role)
  end

  def show
  end

  def edit
  end

  def update
    if @hero.update(hero_params)
      redirect_to @hero, notice: 'Hero was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @hero.destroy
    redirect_to heroes_url, notice: 'Hero was successfully deleted.'
  end

  def import_from_api
    Rails.logger.info "Starting API import process"
    imported_count = MlbbApiService.import_heroes_to_database
    Rails.logger.info "Import completed with #{imported_count} heroes"
    
    if imported_count > 0
      redirect_to heroes_path, notice: "Successfully imported #{imported_count} heroes!"
    else
      redirect_to heroes_path, notice: "No new heroes to import."
    end
  rescue StandardError => e
    Rails.logger.error "Import failed: #{e.message}"
    redirect_to heroes_path, alert: "Import failed: #{e.message}. Please check the logs."
  end

  private

  def set_hero
    @hero = Hero.find(params[:id])
  end

  def hero_params
  params.require(:hero).permit(:name, :role, :specialty, :difficulty, :lane, :description, :image)
  end
end
