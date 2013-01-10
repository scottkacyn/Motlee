class LeadsController < ApplicationController

    def index
        @leads = Leads.all
    end

    def show
        @lead = Leads.find(params[:id])
    end

    def create
        lead = Leads.new(params[:leads])
        newlead = Leads.where(:email => lead.email).first

        if newlead.nil?
            @leads = Leads.create(params[:leads])
            redirect_to(@leads)
        else
            redirect_to(newlead)
        end
    end

end
