FROM ruby:2.5.1-stretch

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y --force-yes \
  build-essential \
  nodejs \
  yarn


ENV RAILS_ENV production
ENV RACK_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app
WORKDIR /app

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5


# Copy the main application.
COPY . ./

# Precompile Assets
RUN bundle exec rake assets:precompile


# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]