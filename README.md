# Autocomplete

_A simple autocomplete class written in Swift_

## What can it do?

- Return a list of strings based on textual user input
- Match strings by prefix, range of text or custom closure
- Load a lookup list from a file or a URL
- Keep a list of most recently selected matches

## Why should I use it?

- Simple to use
- Fast
- A single class

## Sample method call

### `AutocompleteManager.swift`

```Swift

// Use the built in filtering to match starting text
list = autocompleteManager.updateListMatchPrefix(autocompleteField.text)

```

## An example application

A simple application, which is included, shows how to perform prefix and range of text matches to look up world cities or US presidents. It also shows how to maintain a most recents list.


## Limitations

- Only tested with English text

## License

Autocomplete is released under the MIT-license (see the LICENSE file)
