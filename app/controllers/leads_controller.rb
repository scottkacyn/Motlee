class LeadsController < ApplicationController

    def index
        @leads = Leads.all
    end

    def show
        @lead = Leads.find(params[:id])
    end

    def create
        @leads = Leads.create(params[:leads])
        redirect_to(@leads)
    end

end
