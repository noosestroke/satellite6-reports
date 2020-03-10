class Reports
  def self.get_hosts(sat_api, org, export_dir) 
    @sat_api = sat_api
    @org = org
    @export_dir = export_dir
    d = Time.now
    f = "#{export_dir}host-report.csv"
    host_ids = {}
    hosts = []
    results = []

    req = @sat_api.resource(:hosts).call(:index, {:organization_id => org, :per_page => "500"})
    results.concat(req['results'])
    while (req['results'].length == req['per_page'].to_i)
      req = @sat_api.resource(:hosts).call(:index, {:organization_id => org, :per_page => req['per_page'], :page => req['page'].to_i+1})
      results.concat(req['results'])
    end
    File.open(f, "w") do |file|
      file << "hostname, cpu's, cpu_sockets, cpu_cores_per_socket, manufacturer, architecture, timestamp \n"
    end
    results.each do |items|
      host_ids[items['name']] = items['id']
    end
    host_ids.each do |hostname, id|
      metrics = @sat_api.resource(:hosts).call(:show, {:organization_id => org, :id => id, :full_results => true})
      if metrics != nil and metrics['facts'] != nil
        File.open(f, "a") do |file|
            file << "#{hostname}, #{metrics['facts']['lscpu::cpu(s)']}, #{metrics['facts']['dmi::meta::cpu_socket_count']}, #{metrics['facts']['lscpu::core(s)_per_socket']}, #{metrics['facts']['dmi::system::product_name']}, #{metrics['facts']['uname::machine']}, #{d.strftime("%Y/%m/%d %H:%M")}\n"
        end
      else
        File.open(f, "a") do |file|
          file << "No Metrics for host #{hostname}, object not found! \n"
        end
      end
    end
  end

  def self.get_packages(sat_api, org, sat_url, user, pass, export_dir)
    @sat_api = sat_api
    @org = org
    host_ids = {}
    results = []
    d = Time.now
    f = "#{export_dir}packages-per-host.csv"

    req = @sat_api.resource(:hosts).call(:index, {:organization_id => org, :per_page => "500"})
    results.concat(req['results'])
    while (req['results'].length == req['per_page'].to_i)
      req = @sat_api.resource(:hosts).call(:index, {:organization_id => org, :per_page => req['per_page'], :page => req['page'].to_i+1})
      results.concat(req['results'])
    end
    results.each do |items|
      host_ids[items['name']] = items['id']
    end
    File.open(f, "w") do |file|
      file << "hostname,packagename,timestamp \n"
    end
    host_ids.sort.each do |hostname, id|
      uri = URI("#{sat_url}/api/v2/hosts/#{id}/packages?per_page=2000")
      json = nil
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri
        request.basic_auth user, pass
        response = http.request request
	json = JSON.parse(response.body)
      end
      if json != nil and json['results'] != nil
        json['results'].each do |package|
          File.open(f, "a") do |file|
            file << "#{hostname},#{package['nvra']},#{d.strftime("%Y/%m/%d %H:%M")}\n"
          end
        end
      end
    end
  end
end
