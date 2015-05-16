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

## Sample prefix match method - updates autocomplete list of table view


```Swift

@IBAction func editingDidChange(sender: UITextField) {
    let autocompleteField: UITextField = sender
    if !autocompleteField.text.isEmpty {

        // Use the built in filtering to match starting text
        list = autocompleteManager.updateListMatchPrefix(autocompleteField.text)
    }
    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
}

```

## Sample range match method - updates autocomplete list of table view

```Swift

@IBAction func editingDidChange(sender: UITextField) {
    let autocompleteField: UITextField = sender
    if !autocompleteField.text.isEmpty {

        // Use the built in filtering to match contained text
        list = autocompleteManager.updateListMatchAny(autocompleteField.text)
    }
    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
}

```

## Sample closure match method - updates autocomplete list of table view

```Swift

@IBAction func editingDidChange(sender: UITextField) {
    let autocompleteField: UITextField = sender
    if !autocompleteField.text.isEmpty {

        // Use a closure to pass a filter that must match the prefix or the suffix
        list = autocompleteManager.updateList({ $0.lowercaseString.hasPrefix(autocompleteField.text.lowercaseString) || $0.lowercaseString.hasSuffix(autocompleteField.text.lowercaseString) })
    }
    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
}

```

## An example application

A simple application, which is included, shows how to perform prefix and range of text matches to look up world cities or US presidents. It also shows how to maintain a most recents list.


## Limitations

- Only tested with English text

## License

Autocomplete is released under the MIT-license (see the LICENSE file)
