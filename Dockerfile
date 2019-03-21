FROM ruby:2.5

RUN mkdir -p /opt/congress_forms_api
WORKDIR /opt/congress_forms_api

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      git \
      gnupg \
      apt-transport-https \
      libpq-dev \
      postgresql-client \
      libsqlite3-dev && \
    curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable

COPY Gemfile* ./
RUN bundle install

COPY . .

RUN adduser --uid 1000 app && \
    chown -R app /opt/congress_forms_api/tmp && \
    chown -R app /opt/congress_forms_api/log && \
    chown -R app /opt/congress_forms_api/public/screenshots && \
    mkdir -p /opt/congress_forms_api/contact_congress && \
    chown -R app /opt/congress_forms_api/contact_congress && \
    mkdir /opt/congress_forms_api/.chromedriver-helper && \
    chown -R app /opt/congress_forms_api/.chromedriver-helper

USER app

RUN chromedriver-update 73.0.3683.68

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
ENTRYPOINT ["/opt/congress_forms_api/entrypoint.sh"]
