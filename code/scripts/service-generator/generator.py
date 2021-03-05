from jinja2 import Template
import os
import re

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
bc = bcolors()

class Service:
    def __init__(self):
        self.name = str
        self.domains = []
        self.backends = []
        self.default_origin = True
        self.default_caching = True
        self.default_vcl = True
        self.geo_blocking = True
        self.nonprod_acl = True
        self.robots_txt_block_all = False
        self.force_ssl = True
        self.enable_hsts = True
        self.enable_gzip = True
        self.enable_logging = True

class Domain:
    def __init__(self):
        self.name = str
        self.comment = str

class Backend:
    def __init__(self):
        self.name = str
        self.address = str
        self.ssl_cert_hostname = str
        self.port = "var.OriginDefaults.port"
        self.connect_timeout = "var.OriginDefaults.connect_timeout"
        self.use_ssl = "var.OriginDefaults.use_ssl"
        self.min_tls_version = "var.OriginDefaults.min_tls_version"
        self.ssl_check_cert = "var.OriginDefaults.ssl_check_cert"
        self.auto_loadbalance = "var.OriginDefaults.auto_loadbalance"
        self.between_bytes_timeout = "var.OriginDefaults.between_bytes_timeout"
        self.first_byte_timeout = "var.OriginDefaults.first_byte_timeout"
        self.is_default = bool

class ServiceCreator:

    def fmt(self, string, bypass=False):
        string = str(string).strip().lower()

        if not bypass:
            if string == '' or string == ' ':
                return False

        return string

    def user_input(self):
        s = Service()
        
        # Service Name
        print(f'{bc.HEADER}[i]{bc.ENDC} Create a Service Name. This will be the [name] field in Fastly and the service/<name> directory in this repo.')
        s.name = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Service Name [ex: mynewservice.example.com]: '))

        # Service Domains
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Service Domain Names. Choose the domain names that Fastly should use for this service.')
        num_domains = int(input(f'{bc.OKBLUE}[?]{bc.ENDC} Domains(s) - Enter the # of Domains(s) to be used by your Fastly Service: ').strip())

        for i in range(num_domains): #pylint: disable=unused-variable
            print()
            d = Domain()
            d.name = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Domain {bc.HEADER}{i + 1}{bc.ENDC} name value [ex: mynewservice.example.com]: '))
            d.comment = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Domain {bc.HEADER}{i + 1}{bc.ENDC} comment value [ex: mynewservice.example.com prod domain]: '))

            s.domains.append(d)

        # Service Backends
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Service Backends. Choose the backends that Fastly should use for this service.')
        num_backends = int(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backends(s) - Enter the # of Backends(s) to be used by your Fastly Service: ').strip())

        default_check = False
        for i in range(num_backends): #pylint: disable=unused-variable
            print()
            b = Backend()
            b.name = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} name - Replace "." with "_" - [ex: my_backend_example_com_443]: '))
            b.address = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} address - [ex: mybackend.app.example.com]: '))
            b.ssl_cert_hostname = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} ssl_cert_hostname - [ex: mybackend.app.example.com]: '))
            port = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} port - blank for default [ex: 443]: '))
            if port: b.port = port
            connect_timeout = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} connect_timeout - blank for default [ex: 3000]: '))
            if connect_timeout: b.connect_timeout = connect_timeout
            use_ssl = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} use_ssl - blank for default [ex: true|false]: '))
            if use_ssl: b.use_ssl = use_ssl
            min_tls_version = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} min_tls_version - blank for default [ex: 1.2]: '))
            if min_tls_version: b.min_tls_version = min_tls_version
            ssl_check_cert = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} ssl_check_cert - blank for default [ex: true|false]: '))
            if ssl_check_cert: b.ssl_check_cert = ssl_check_cert
            auto_loadbalance = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} auto_loadbalance - blank for default [ex: true|false]: '))
            if auto_loadbalance: b.auto_loadbalance = auto_loadbalance
            between_bytes_timeout = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} between_bytes_timeout - blank for default [ex: 12000]: '))
            if between_bytes_timeout: b.between_bytes_timeout = between_bytes_timeout
            first_byte_timeout = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} first_byte_timeout - blank for default [ex: 5000]: '))
            if first_byte_timeout: b.first_byte_timeout = first_byte_timeout

            if not default_check:
                is_default = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Backend {bc.HEADER}{i + 1}{bc.ENDC} is default origin - blank for default (true) [ex: true|false]: '), bypass=True)
                if is_default == 'false' or is_default == 'False' or is_default == False:
                    is_default = False
                else: 
                    is_default = True
                    default_check = True
                b.is_default = is_default
            else:
                print(f'{bc.OKBLUE}[i]{bc.ENDC} Default Origin Check has been previously set for another backend. Skipping 👍')
                b.is_default = False

            s.backends.append(b)

        # Default Origin Condition
        if len(s.backends) > 1:
            print(f'\n{bc.HEADER}[i]{bc.ENDC} Default Origin Condtion. More than one backend detected. Would you like to auto-generate a default origin condition?')
            default_origin = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Auto-Generate - blank for default (y) [ex: y/n]: '))
            if default_origin:
                if 'n' in default_origin: s.default_origin = False

        # Default Caching
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Default Caching. Would you like to generate default caching logic? If you don\'t use default logic you will have to create it yourself by hand')
        default_caching = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Use Default Caching - blank for default (y) [ex: y|n]: '))
        if default_caching:
            if 'n' in default_caching: s.default_caching = False

        # Default VCL
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Default VCL. Would you like to generate default VCL logic? If you don\'t use default logic you will have to create it yourself by hand')
        default_vcl = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Use Default VCL Statements - blank for default (y) [ex: y|n]: '))
        if default_vcl:
            if 'n' in default_vcl: s.default_vcl = False

        # Geo Blocking
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Enable Geo Blocking - This will block IPs based on country codes example has deemed to be bad.')
        geo_blocking = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Enable Geo Blocking - blank for default (y) [ex: y|n]: '))
        if geo_blocking:
            if 'n' in geo_blocking: s.geo_blocking = False

        # NonProd ACLs
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Enable NonProd ACLs - This will block all connections that are not defined in acl protection policies.')
        nonprod_acl = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Enable NonProd ACLs - blank for default (y) [ex: y|n]: '))
        if nonprod_acl:
            if 'n' in nonprod_acl: s.nonprod_acl = False

        # Robots TXT Block all
        print(f'\n{bc.HEADER}[i]{bc.ENDC} robots.txt Block All - This will block all crawlers via the robots.txt file.')
        robots_txt_block_all = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Enable robots.txt block - blank for default (n) [ex: y|n]: '))
        if robots_txt_block_all:
            if 'y' in robots_txt_block_all: s.robots_txt_block_all = True

        # Force SSL/TLS
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Force SSL/TLS.')
        force_ssl = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Enable Force SSL/TLS - blank for default (y) [ex: y|n]: '))
        if force_ssl:
            if 'n' in force_ssl: s.force_ssl = False

        # Enable HSTS
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Enable Default HSTS Policy.')
        enable_hsts = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Enable Default HSTS Policy - blank for default (y) [ex: y|n]: '))
        if enable_hsts:
            if 'n' in enable_hsts: s.enable_hsts = False

        # Enable GZIP
        print(f'\n{bc.HEADER}[i]{bc.ENDC} Enable Default GZIP Policy')
        enable_gzip = self.fmt(input(f'{bc.OKBLUE}[?]{bc.ENDC} Enable Default GZIP Policy - blank for default (y) [ex: y|n]: '))
        if enable_gzip:
            if 'n' in enable_gzip: s.enable_gzip = False

        return s

    def render_config_tf(self, s):
        template = Template(open('code/scripts/service-generator/_template/config.tf').read())
        t = template.render(name=s.name)
        
        with open(f'services/{s.name}/config.tf', 'w') as config:
            config.write(t)

    def render_fastly_tf(self, s):
        template = Template(open('code/scripts/service-generator/_template/fastly.tf').read())
        t = template.render(s=s)
        
        with open(f'services/{s.name}/fastly.tf', 'w') as config:
            config.write(t)

    def render_fastly_vcl(self, s):
        template = Template(open('code/scripts/service-generator/_template/fastly.vcl').read())
        t = template.render(s=s)
        
        with open(f'services/{s.name}/fastly.vcl', 'w') as config:
            config.write(t)

    def render_ci_yml(self, s):
        template = Template(open('code/scripts/service-generator/ci-template.yml').read())
        t = template.render(s=s) + '\n'

        with open(f'.gitlab-ci.yml', 'a') as yml:
            yml.write(t)

    def create_dir(self, s):
        try:
            os.mkdir(f'services/{s.name}')
        except FileExistsError:
            print(f'{bc.WARNING}[!]{bc.ENDC} services/{s.name} folder already exists.')

def main():

    sc = ServiceCreator()

    print(f'{bc.HEADER}############ Fastly Service Config Generator v1 ############{bc.ENDC}')
    print(f'{bc.HEADER}[i]{bc.ENDC} Please see the guide to use this script if you have any questions:')
    print(f'docs/new-service.md (suggested)')
    print(f'docs/getting-started.md (optional)\n')
    s = sc.user_input()

    sc.create_dir(s)
    sc.render_config_tf(s)
    sc.render_fastly_tf(s)
    sc.render_fastly_vcl(s)
    sc.render_ci_yml(s)

    print(f'\n{bc.OKGREEN}[i]{bc.ENDC} Service Created Successfully ✔️')
    print(f'{bc.HEADER}[i]{bc.ENDC} View your new service in the following folder: {bc.OKBLUE}services/{s.name}{bc.ENDC}')
    print(f'\n{bc.OKGREEN}[i]{bc.ENDC} Done!')


if __name__ == "__main__":
    main()