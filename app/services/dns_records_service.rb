class DnsRecordsService
  def initialize(params = {})
    @included = params[:included]
    @excluded = params[:excluded]
    @page = params[:page].to_i || 1
  end

  def call
    {
      total_records: paginated_records.count,
      records: paginated_records.map { |record| { id: record.id, ip: record.ip } },
      related_hostnames: related_hostnames
    }
  end

  private
  def paginated_records
    dns_records = DnsRecord.joins(:hostnames).order(:id)

    if @excluded.present? && @included.present?
      dns_records = dns_records.where("dns_records.id NOT IN (?) AND dns_records.id IN (?)", excluded_records, included_records)
    else

      if @excluded.present?
        dns_records = dns_records.where.not(id: excluded_records)
      end

      if @included.present?
        dns_records = dns_records.where(id: included_records)
      end
    end
    dns_records.distinct.paginate(page: @page, per_page: 5)
  end

  def included_records
    DnsRecord.joins(:hostnames)
             .where(hostnames: { hostname: @included.split(',') })
             .group('dns_records.id')
             .having('COUNT(*) = ?', @included.split(',').size)
             .pluck(:id)
  end

  def excluded_records
    DnsRecord.joins(:hostnames)
             .where(hostnames: { hostname: @excluded.split(',') })
             .pluck(:id)
  end

  def related_hostnames
    all_hostnames = paginated_records.flat_map { |record| related_hostnames_for_record(record) }


    unique_hostnames = if @included.present?
                         Hostname.where(dns_record_id: paginated_records.ids).where(hostname: @included.split(',')).uniq { |h| h['hostname'] }
                       else
                         Hostname.where(dns_record_id: paginated_records.ids).uniq { |h| h['hostname'] }
                       end

    unique_hostnames.map do |hostname|
      {
        hostname: hostname['hostname'],
        count: all_hostnames.count { |h| h['hostname'] == hostname['hostname'] }
      }
    end
  end

  def related_hostnames_for_record(record)
    paginated_hostnames = record.hostnames
    paginated_hostnames.select(:hostname).as_json(except: :id)
  end
end
