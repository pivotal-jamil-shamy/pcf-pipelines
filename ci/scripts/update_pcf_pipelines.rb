#!/usr/bin/env ruby

require 'tempfile'
require 'yaml'

params = {}
def load_param(note_path)
  lpass_path = "Shared-PCF-NORM/#{note_path}"
  creds = `lpass show #{lpass_path}  --notes`.chomp

  if creds.empty?
    puts "Could not fetch creds from #{lpass_path}"
    puts creds
    exit(1)
  end

  creds
end




params['rc_aws_install_params'] = load_param('rc/install-pcf/aws/pipeline.yml')
params['rc_gcp_install_params'] = load_param('rc/install-pcf/gcp/pipeline.yml')
params['rc_azure_install_params'] = load_param('rc/install-pcf/azure/pipeline.yml')
params['rc_vsphere_install_params'] = load_param('rc/install-pcf/vsphere/pipeline.yml')
params['rc_lre_gcp_upgrade_ops_manager_params'] = load_param('lre/upgrade-ops-manager/gcp/pipeline.yml')
params['rc_gcp_upgrade_pas_tile_params'] = load_param('rc/upgrade-pas-tile/gcp/pipeline.yml')
params['unpack_pcf_pipelines_combined_params'] = {
    'rc_offline_vsphere_install_params' => load_param('offline/install-pcf/vsphere/pipeline.yml'),
    'rc_offline_pipeline_name' => 'rc-offline-vsphere-install'
}.to_yaml

file = Tempfile.new('pipeline_params')
file.write(params.to_yaml)
file.close

flyCmd = "fly -t ci sp -p pcf-pipelines-master -c ci/pcf-pipelines/pipeline.yml \
  -l #{file.path} \
  -l <(lpass show Shared-PCF-NORM/pcf-pipelines-params --notes) \
  -l <(lpass show Shared-PCF-NORM/pcf-norm-github --notes) \
  -l <(lpass show Shared-PCF-NORM/norm-pivnet --notes) \
  -l <(lpass show Shared-PCF-NORM/czero-mineo-lrpiec03 --notes)"

puts flyCmd

exec "bash -c '#{flyCmd}'"