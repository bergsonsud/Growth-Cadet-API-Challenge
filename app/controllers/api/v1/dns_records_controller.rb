module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        if index_params[:page].blank?
          render json: { errors: 'Page param is required' }, status: :unprocessable_entity
        else
          render json: DnsRecordsService.new(index_params.slice(:page, :included, :excluded)).call
        end
      end

      # POST /dns_records
      def create
        @dns_record = DnsRecord.new(dns_record_params)

        if @dns_record.save
          render json: { message: 'DNS record created successfully' }, status: :created
        else
          render json: { errors: @dns_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      protected

      def index_params
        params.permit(:page, :included, :excluded, dns_record: {})
      end

      def dns_record_params
        params.require(:dns_record).permit(:ip, hostnames_attributes: [:hostname])
      end
    end
  end
end
