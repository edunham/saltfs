{% from tpldir ~ '/map.jinja' import tracker %}

tracker-debugging-packages:
  pip.installed:
    - pkgs:
      - github3.py == 1.0.0a4

intermittent-tracker:
  virtualenv.managed:
    - name: /home/servo/intermittent-tracker/_venv
    - venv_bin: virtualenv-3.5
    - python: python3
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/Manishearth/intermittent-tracker@{{ tracker.rev }}
    - bin_env: /home/servo/intermittent-tracker/_venv
    - require:
      - virtualenv: intermittent-tracker
  service.running:
    - enable: True
    - name: tracker
    - require:
      - pip: intermittent-tracker
    - watch:
      - file: /home/servo/intermittent-tracker/config.json
      - file: /etc/init/tracker.conf

/home/servo/intermittent-tracker/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/etc/init/tracker.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/tracker.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: intermittent-tracker
      - file: /home/servo/intermittent-tracker/config.json
