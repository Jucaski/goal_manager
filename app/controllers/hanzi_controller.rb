class HanziController < ApplicationController
  def show
    hanzi = Hanzi.find_by!(character: params[:character])
    render json: { strokes: hanzi.strokes, medians: hanzi.medians }
  end
end
