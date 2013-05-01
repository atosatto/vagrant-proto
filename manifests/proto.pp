######################################################
#          Proto Vagrant VM puppet module            #
#                                                    #
#    -*- Andrea Tosatto <andrea@tosatto.me> -*-      #
######################################################

class { 'apt': 
  always_apt_update => true,
}

package{
    # Generic Dependencies
    ['wget']:
        ensure  => latest,
        require => Class['apt'];
    
    # Build Dependencies
    ['autoconf', 'libtool', 'build-essential', 'libglu1-mesa-dev', 'freeglut3-dev', 
    'mesa-common-dev', 'libxmu-dev', 'libxi-dev', 'flex']:
        ensure => latest,
        require => Class['apt'];
    
}


## Proto Deployment Configurations ##
$proto_location  = "/home/vagrant/proto"
$proto_release   = "release7"
$proto_tar_dir   = "release-7"
$proto_url       = "http://proto.bbn.com/Proto/Downloads_files/proto-${proto_release}.tgz"

exec {

  'Download Proto':
    command     => "wget --output-document=/tmp/proto-${proto_release}.tgz ${proto_url}",
    provider    => "shell",
#    cwd         => "/tmp",
    creates     => "/tmp/proto-${proto_release}.tgz",
    require     => [Package['wget']];
  
  'Untar Proto':
    command     => "tar -zxvf /tmp/proto-${proto_release}.tgz",
    provider    => 'shell',
    cwd         => "/tmp",
    creates     => "/tmp/${proto_tar_dir}/proto",
    require     => [
      Exec['Download Proto'],
    ];
  
  'Install Proto Step1':
    command     => "./autogen.sh",
    provider    => 'shell',
    cwd         => "/tmp/${proto_tar_dir}/proto",
    creates     => "/tmp/${proto_tar_dir}/proto/INSTALL",
    require     => [
      Exec['Untar Proto'],
      Package['autoconf'], 
      Package['libtool'], 
      Package['build-essential'], 
      Package['libglu1-mesa-dev'], 
      Package['freeglut3-dev'], 
      Package['mesa-common-dev'], 
      Package['libxmu-dev'], 
      Package['libxi-dev'], 
      Package['flex'],
    ];
  
  'Install Proto Step2':
    command     => "./configure; make; sudo make install",
    provider    => 'shell',
    cwd         => "/tmp/${proto_tar_dir}/proto",
    creates     => "/usr/local/share/proto/",
    require     => [
      Exec['Install Proto Step1'],
    ];
    
}