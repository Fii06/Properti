class ImagesController < ApplicationController
  def show
    file = Mongoid::GridFs.find(params[:id])
    send_data file.data,
      filename: file.filename,
      type: file.content_type,
      disposition: "inline"
  end
end
