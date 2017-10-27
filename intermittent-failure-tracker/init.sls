{% from tpldir ~ '/map.jinja' import tracker %}

include:
  - python

intermittent-failure-tracker:
  virtualenv.managed:
    - name: /home/servo/intermittent-failure-tracker/_venv
    - venv_bin: virtualenv-3.5
    - python: python3
    - system_site_packages: False
    - require:
      - pkg: python3
      - pip: virtualenv
  pip.installed:
    - pkgs:
      - git+https://github.com/servo/intermittent-failure-tracker@{{ tracker.rev }}
    - bin_env: /home/servo/intermittent-failure-tracker/_venv
    - require:
      - virtualenv: intermittent-failure-tracker
  {% if grains.get('virtual_subtype', '') != 'Docker' %}
  service.running:
    - enable: True
    - name: failure-tracker
    - require:
      - pip: intermittent-failure-tracker
    - watch:
      - file: /home/servo/intermittent-failure-tracker/config.json
      - file: /etc/init/failure-tracker.conf
  {% endif %}

/home/servo/intermittent-failure-tracker/config.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/config.json
    - template: jinja
    - user: servo
    - group: servo
    - mode: 644

/etc/init/failure-tracker.conf:
  file.managed:
    - source: salt://{{ tpldir }}/files/tracker.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pip: intermittent-failure-tracker
      - file: /home/servo/intermittent-failure-tracker/config.json