class ConceptsController < ApplicationController
  respond_to :html, :xml, :json

  def update
    @concept = Concept.find(params[:id])
    @concept.update_attributes(params[:concept].permit(:tag))
    respond_with @concept.article
  end
end
