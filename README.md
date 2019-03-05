# CongressForms API

This is a Rails app providing a JSON-based API for the [EFForg/congress_forms](https://github.com/EFForg/congress_forms) gem.

## Installation

Start by coping the example config.

```
$ cp .env.example .env
$ cp docker-compose.yml.example docker-compose.yml # if using docker
```

Fill in the `DATABASE_*` variables with your postgres address/credentials, and the `CWC_*` variables with your Communicating with Congress vendor information (see the [congress_forms](https://github.com/EFForg/congress_forms#operation-and-configuration) README for more documentation on CWC).

The `ADMIN_*` variables are optional. They set the basic auth credentials used by the [/delayed_job](https://github.com/ejschmitt/delayed_job_web) admin area.

`DEBUG_KEY` is required for access to some API endpoints. Read the [API documentation](#api-documentation) for more information.

If you're using docker, at this point you can build the containers. Either way be sure to run `rake db:setup` to initialize the database, and then you should be done!

## Delayed Messages

When a message can't be delivered, it is saved into a [delayed_job](https://github.com/collectiveidea/delayed_job) queue and attempted again later. To process this queue you need to run a delayed job worker:

```
$ rake jobs:work
```

The example docker-compose configuration includes a container running this command.

## API Documentation
 See [public/index.md](https://github.com/EFForg/congress_forms_api/blob/master/public/index.md).

## License

The code is available as open source under the terms of the [GPLv3 License](https://github.com/EFForg/congress_forms_api/blob/master/LICENSE.txt).
