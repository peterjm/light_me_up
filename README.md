# LightMeUp

A command-line tool for controlling [Elgato Key Lights](https://www.elgato.com/us/en/p/key-light) from your terminal.

## Installation

    $ gem install light_me_up

## Usage

```
light-me-up [options]
```

### Options

| Option | Description |
|---|---|
| `--on` | Turn the light on |
| `--off`, `-O` | Turn the light off |
| `--toggle`, `-T` | Toggle the light on or off |
| `--brightness N` | Set brightness (0 to 100) |
| `--temperature N` | Set color temperature (0 to 100) |
| `--defaults` | Set brightness and temperature to default values |
| `--ip-address ADDR` | Specify the light's IP address |
| `--version` | Print version number and exit |

### Examples

```bash
# Turn the light on
light-me-up --on

# Turn the light off
light-me-up --off

# Set brightness and temperature
light-me-up --on --brightness 75 --temperature 50

# Toggle the light on or off
light-me-up --toggle

# Use default brightness and temperature
light-me-up --on --defaults
```

### Environment Variables

| Variable | Description |
|---|---|
| `ELGATO_IP_ADDRESS` | Default IP address of the light (used when `--ip-address` is not provided) |
| `ELGATO_DEFAULT_BRIGHTNESS` | Default brightness value for `--defaults` |
| `ELGATO_DEFAULT_TEMPERATURE` | Default temperature value for `--defaults` |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/peterjm/light_me_up. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/peterjm/light_me_up/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
