# Controller for managing images
class ImagesController < ApplicationController
  
  layout "application"

  before_filter :authenticate
  before_filter :load_image, only: [ :index, :create ]

  # Displays an administration interface for the images
  # associated with a culture provider or an event
  def index
  end

  # Sets the main image (logotype) of a culture provider.
  def set_main
    culture_provider = CultureProvider.find params[:culture_provider_id]
    image = Image.find params[:id]

    culture_provider.main_image = image
    culture_provider.save!

    redirect_to culture_provider_images_url(culture_provider)
  end

  def create
    if @image.save
      if @image.culture_provider
        redirect_to culture_provider_images_url(@image.culture_provider)
      elsif @image.event
        redirect_to event_images_url(@image.event)
      end

      flash[:notice] = "Bilden laddades upp."
    else
      render action: "index"
    end
  end

  def destroy
    image = Image.find params[:id]

    if image.culture_provider

      if image.culture_provider.main_image_id == image.id
        image.culture_provider.main_image = nil
        image.culture_provider.save!
      end
      
      redirect_to culture_provider_images_url(image.culture_provider)
    elsif image.event
      redirect_to event_images_url(image.event)
    end

    image.destroy

    flash[:notice] = "Bilden togs bort"
  end

  protected

  # Load the working image, the culture provider/event and all its images.
  def load_image
    @image = Image.new params[:image]

    if params[:culture_provider_id]
      @image.culture_provider = CultureProvider.find params[:culture_provider_id]
      @images = @image.culture_provider.images
    elsif params[:event_id]
      @image.event = Event.find params[:event_id]
      @images = @image.event.images
    else
      flash[:error] = "Felaktigt anrop."
      redirect_to root_url()
    end
  end

end
