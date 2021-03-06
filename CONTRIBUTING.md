# Contributing

It is recommended that you go through
[our workshop](https://github.com/acs-upb-mobile/flutter-workshop) first, to familiarize yourself
with the technologies and the contribution process.

## Pull Request process

1. Check out [this](https://opensource.com/article/19/7/create-pull-request-github) tutorial if you
don't know how to make a PR.
2. Increase the version number in the [`pubspec.yaml`](pubspec.yaml) file with the following
guidelines in mind:
    - **Build number** (0.2.1+**4**) is for very small changes and bug fixes (usually not visible to
      the end user).
    - **Patch version** (0.2.**1**+4) is for minor improvements that may be visible to an attentive
      end user.
    - **Minor version** (0.**2**.1+4) is for added functionality (i.e. merging a branch that
      introduces a new feature).
    - **Major version** (**0**.2.1+4) marks important project milestones.
3. Document any non-obvious parts of the code and make sure the commit description is clear on why
the change is necessary.
4. If it's a new feature, write at least one test for it.

## Development tips

* Make sure you have the *Project* view open in the *Project* tab on the left in Android Studio (not
*Android*).
* Flutter comes with *Hot Reload* (the lightning icon, or *Ctrl+\\* / *⌘\\*), which allows you to
load changes in the code quickly into an already running app, without you needing to reinstall it.
It's a very handy feature, but it doesn't work all the time - if you change the code, use Hot Reload
but don't see the expected changes, or see some weird behaviour, you may need to close and restart
the app (or even reinstall).
* If running on web doesn't give the expected results after changing some code, you may need to
clear the cache (in *Chrome*: *Ctrl+Shift+C* / *⌘+Shift+C* to open the Inspect menu, then
right-click the *Refresh* button, and select *Empty cache and Hard reload*.)

## Style guide

This project uses
[the official Dart style guide](https://dart.dev/guides/language/effective-dart/style)  with the
following mentions:

* Android Studio (IntelliJ) with the `dartfmt` tool is used to automatically format the code,
including the order of imports.
* For consistency, the `new` keyword (which is optional in Dart) should **not** be used.
* Where necessary, comments should use Markdown formatting (e.g. backticks - \` - for code snippets
and `[brackets]` for code references).
* Use only single apostrophes - ' - for strings (e.g. `'hello'` instead of `"hello"`)

## Working with Firebase
This application uses [Firebase](https://firebase.google.com/) to manage remote storage and
authentication.

### Setup
This application uses [flutterfire](https://github.com/FirebaseExtended/flutterfire) plugins in
order to access Firebase services. They are already enabled in the [pubspec](pubspec.yaml) file and
ready to import and use in the code.

### Firestore
[Cloud Firestore](https://firebase.google.com/docs/firestore) is a noSQL database that organises
its data in *collections* and *documents*.

#### Data model
**Collections** are simply a list of documents, where each document has an ID within the collection.

**Documents** are similar to a JSON file (or a C `struct`, if you prefer), in that they contain
different fields which have three important components: a ***name*** - what we use to refer to the
field, similar to a dictionary key -, a ***type*** (which can be one of `string`, `number`,
`boolean`, `map`, `array`, `null` - yeah *null* is its own type -, `timestamp`, `geopoint`,
`reference` - sort of like a pointer to another document), and the actual ***value***, the data
contained in the field.  
In addition to fields, documents can contain collections... which contain other documents... which
can contain collections, and so on and so forth, allowing us to create a hierarchical structure
within the database.

More information about the Firestore data model can be found
[here](https://firebase.google.com/docs/firestore/data-model).

#### Security

Firestore allows for defining specific security rules for each collection. Rules can be applied for
each different type of transaction - `reads` (where single-document reads - `get` - and queries -
`list` - can have different rules) and `writes` (where `create`, `delete` and `update` can be
treated separately).

More information on Firestore security rules can be found
[here](https://firebase.google.com/docs/firestore/security/rules-structure).

#### Project database
The project database contains the following collections:

<details>
<summary><b>users</b></summary>
This collection stores per-user data. The document key is the user's `uid` (from
<a href=https://firebase.google.com/docs/auth>FirebaseAuth</a>).

###### Fields
All the documents in the collection share the same structure:

<table>
  <tr>
    <th>Field</th>
    <th>Type</th>
    <th>Required?</th>
    <th>Additional info</th>
  </tr>
  <tr>
    <td>group</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>e.g. “314CB”</td>
  </tr>
  <tr>
    <td>name</td>
    <td><code>map&lt;string, string&gt;</code></td>
    <td>🗹</td>
    <td>keys are “first” and “last”</td>
  </tr>
  <tr>
    <td>permissionLevel</td>
    <td><code>number</code></td>
    <td>☐</td>
    <td>a numeric value that defines what the user is allowed to do; if missing, it is treated as
    being equal to zero</td>
  </tr>
</table>

###### Sub-collections
* **websites**  
A user can define their own websites, that only they have access to. These will reside in the
__websites__ sub-collection, and have the following field structure, similar to the one in the
root-level <a href=#websites-collection>websites</a> collection:
<table>
  <tr>
    <th>Field</th>
    <th>Type</th>
    <th>Required?</th>
    <th>Additional info</th>
  </tr>
  <tr>
    <td>category</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>one of: “learning”, “association”, “administrative”, “resource”, “other”</td>
  </tr>
  <tr>
    <td>icon</td>
    <td><code>string</code></td>
    <td>☐</td>
    <td>path in Firebase Storage; if missing, it defaults to "icons/websites/globe.png"</td>
  </tr>
  <tr>
    <td>label</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>unless specified, the app sets this to be the link without the protocol</td>
  </tr>
  <tr>
    <td>link</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>it needs to include the protocol</td>
  </tr>
</table>

###### Rules

Anyone can **create** a new user (a new document in this collection) _if the `permissionLevel` of
the created user is 0, null or not set at all_.

Authenticated users can only **read**, **delete** and **update** their own document (including its
subcollections) and no one else's. However, they cannot modify the `permissionLevel` field.

</details>

<details>
<summary class="collection" id="websites-collection"><b>websites</b></summary>
This collection stores useful websites, shown in the app under the *Portal* page. Who they are
relevant for depends on the `degree` and `relevance` fields (for more information, see the
<a href=#filters-collection>filters</a> collection).

###### Fields
All the documents in the collection share the same structure:
<table>
  <tr>
    <th>Field</th>
    <th>Type</th>
    <th>Required?</th>
    <th>Additional info</th>
  </tr>
  <tr>
    <td>category</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>one of: “learning”, “association”, “administrative”, “resource”, “other”</td>
  </tr>
  <tr>
    <td>degree</td>
    <td><code>string</code></td>
    <td>⍰</td>
    <td>“BSc” or “MSc”, must be specified if relevance is not *null*</td>
  </tr>
  <tr>
    <td>editedBy</td>
    <td><code>array&lt;string&gt;</code></td>
    <td>☐</td>
    <td>list of user IDs</td>
  </tr>
  <tr>
    <td>icon</td>
    <td><code>string</code></td>
    <td>☐</td>
    <td>path in Firebase Storage; if missing, it defaults to "icons/websites/globe.png"</td>
  </tr>
  <tr>
    <td>label</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>unless specified, the app sets this to be the link without the protocol</td>
  </tr>
  <tr>
    <td>link</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>it needs to include the protocol</td>
  </tr>
  <tr>
    <td>relevance</td>
    <td><code>null / list&lt;string&gt;</code></td>
    <td>🗹</td>
    <td>*null* if relevant for everyone, otherwise a string of filter node names</td>
  </tr>
</table>

###### Rules

Since websites in this collection are public information (_anyone can **read**_), altering and
adding data here is a privilege and needs to be monitored, therefore _anyone who wants to modify
this data needs to be authenticated_ in the first place.

Users can **create** a new public website only _if their `permissionLevel` is equal to or greater
than three and they sign the data by putting their `uid` in the `addedBy` field_.

Users can **update** a website _if they do not modify the `addedBy` field and they sign the
modification by adding their `uid` at the end of the `editedBy` list_.

Users can only **delete** a website _if they are the ones who created it_ (their `uid` is equal to
the `addedBy` field) _or if their `permissionLevel` is equal to or greater than four_.

</details>

<details>
<summary class="collection" id="filters-collection"><b>filters</b></summary>
This collection stores <a href=lib/pages/filter/model/filter.dart><code>Filter</code></a> objects.
These are basically trees with named nodes and levels. In the case of the relevance filter, they are
meant to represent the way the University organises students:

```
                                  All
                    _______________|_______________
                  /                                \
                BSc                               MSc       // Degree
         ________|________                 ________|__ ...
       /                  \              /     |
      IS                 CTI            IA   SPRC ...       // Specialization
   ...|...          ______|______       ⋮      ⋮
                  /    |     |   \
               CTI-1 CTI-2 CTI-3 CTI-4                      // Year
                  ⋮    ⋮   __|... ⋮
                        /   |
                     3-CA 3-CB ...                          // Series
                     __|...
                   /   |
               331CA 332CA ...                              // Group
```

###### Fields
All the documents in the collection share the same structure:

<table>
  <tr>
    <th>Field</th>
    <th>Type</th>
    <th>Required?</th>
    <th>Additional info</th>
  </tr>
  <tr>
    <td>levelNames</td>
    <td><code>array&lt;map&lt;string, string&gt;&gt;</code></td>
    <td>🗹</td>
    <td>localized names for each tree level (e.g. "Year"); the map keys are the locale strings
    ("en", "ro")</td>
  </tr>
  <tr>
    <td>root</td>
    <td><code>map&lt;string, map&lt;string, map&lt;...&gt;&gt;&gt;</code></td>
    <td>🗹</td>
    <td>nested map representing the tree structure, where the key is the name of the node and the
    value is a map of its children; the leaf nodes have an empty map as a value, **not** *null* or
    something else</td>
  </tr>
</table>

###### Rules

Filter structure is public information and should never (or very rarely) need to be modified,
therefore for this collection, _anyone can **read**_ but _no one can **write**_.

</details>

</details>

<details>
<summary class="collection" id="import_moodle-collection"><b>import_moodle</b></summary>
This collection contains class data imported directly from the University's Moodle instance. The
data is exported as a spreadsheet from Moodle, and imported to our app's Firestore using
<a href="https://github.com/acs-upb-mobile/data-import/blob/master/import.js">a Node.js script</a>.
Additional information about classes is stored in the <a href=#classes-collection>classes</a> collection.

###### Fields
The structure of the documents in the collection is the same as the columns in the export file:

<img src="screenshots/other/import_moodle.png"><br>

All of the fields are `strings`. In the app, `shortname` is used to extract the class' acronym,
`fullname` is the class' name, and `category_path` defines the category under which the class is
listed on the [ClassesPage](lib/pages/classes/view/classes_page.dart).

###### Rules

This is public information already available on [Moodle](https://acs.curs.pub.ro/), and will never
be editable directly through the app. Therefore for this collection, _anyone can **read**_ but
 _no one can **write**_.

</details>

<details>
<summary class="collection" id="classes-collection"><b>classes</b></summary>
This collection stores information about classes defined in the
<a href=#import_moodle-collection>import_moodle</a> collection. The ID of a document in this
collection corresponds to an ID of a document in
<a href=#import_moodle-collection>import_moodle</a>.

###### Fields
All the documents in the collection share the same structure:
<table>
  <tr>
    <th>Field</th>
    <th>Type</th>
    <th>Required?</th>
    <th>Additional info</th>
  </tr>
  <tr>
    <td>grading</td>
    <td><code>map&lt;string, number&gt;</code></td>
    <td>☐</td>
    <td>map where the key is the name of the evaluation (e.g. “Exam”) and the value is the number
    of points that specific evaluation weighs (generally out of 10 total)</td>
  </tr>
  <tr>
    <td>lecturer</td>
    <td><code>string</code></td>
    <td>☐</td>
    <td>the ID of a person in the <a href=#people-collection>people</a> collection</td>
  </tr>
  <tr>
    <td>shortcuts</td>
    <td><code>array&lt;map&lt;string, string&gt;&gt;</code></td>
    <td>☐</td>
    <td>array of maps representing relevant links for a class, similar to websites; map keys are
    "addedBy", "link", "name", and "type", with "type" being one of "main", "classbook", "resource"
    and  "other"</td>
  </tr>
</table>

###### Rules

Since classes in this collection are public information (_anyone can **read**_), altering and
adding data here is a privilege and needs to be monitored, therefore _anyone who wants to modify
this data needs to be authenticated_ in the first place.

Users can **update** an existing class document _if their `permissionLevel` is equal to or greater
than three_. Additionally, they can only **create** a new class document if a document with that
specific ID exists in the <a href=#import_moodle-collection>import_moodle</a> collection.

Documents in this collection cannot be **delete**d.

</details>

<details>
<summary class="collection" id="people-collection"><b>people</b></summary>
This collection currently contains information about faculty staff, extracted from the
<a href="https://cs.pub.ro/index.php/?option=com_comprofiler&task=userslist&listid=2">official
website</a> using <a href="https://github.com/acs-upb-mobile/data-import/blob/master/crawlers/prof_info_scraper.py">a Python scraper</a>.

###### Fields
All the documents in the collection share the same structure:
<table>
  <tr>
    <th>Field</th>
    <th>Type</th>
    <th>Required?</th>
    <th>Additional info</th>
  </tr>
  <tr>
    <td>email</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td></td>
  </tr>
  <tr>
    <td>name</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td></td>
  </tr>
  <tr>
    <td>office</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td></td>
  </tr>
  <tr>
    <td>phone</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td></td>
  </tr>
  <tr>
    <td>photo</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>a link to the person's photo</td>
  </tr>
  <tr>
    <td>position</td>
    <td><code>string</code></td>
    <td>🗹</td>
    <td>the person's position within the faculty, e.g. "Professor, Dr."</td>
  </tr>
</table>

###### Rules

This is public information already available on
[the official website](https://cs.pub.ro/index.php/?option=com_comprofiler&task=userslist&listid=2),
and currently cannot be edited through the app due to privacy concerns. Therefore for this
collection, _anyone can **read**_ but _no one can **write**_.

</details>

## Internationalization

### On-device
All strings that are visible to the user should be internationalised and set in the corresponding
`.arb` files within the [`l10n`](lib/l10n) folder. The
[Flutter Intl](https://plugins.jetbrains.com/plugin/13666-flutter-intl) Android Studio plugin does
all the hard work for you by generating the code when you save an `.arb` file. Strings can then be
accessed using `S.of(context).stringID`.

### Remote
In the database, internationalized strings are saved as a dictionary where the locale is the key:
```
{
    'ro': 'Îmi place Flutter!',
    'en': 'I like Flutter!'
}
```
These will have a corresponding `Map` variable in the Dart code (e.g. `Map<String, String>
infoByLocale`). See [`WebsiteProvider`](lib/pages/portal/service/website_provider.dart) for a
serialization/deserialization example.


### Changing the locale
Changing the app's language is done via the [settings page](lib/pages/settings/settings_page.dart).

### Fetching the locale
The [`LocaleProvider`](lib/resources/locale_provider.dart) class offers utility methods for
fetching the current locale string. See [`PortalPage`](lib/pages/portal/view/portal_page.dart)
for a usage example.

## Custom icons

If you need to use icons other than the ones provided by the
[Material library](https://material.io/resources/icons), the process is as follows:

### Generating the font file
* Convert the `.ttf` [custom font](assets/fonts/CustomIcons/CustomIcons.ttf) in the project to an
`.svg` font (using a tool such as [this one](https://convertio.co/ttf-svg/)).
* Go to [FlutterIcon](https://fluttericon.com/) and upload (drag & drop) the file you obtained
earlier in order to import the icons.
* Check that the imported icons are the ones defined in the
[`CustomIcons`](lib/resources/custom_icons.dart) class to make sure nothing went wrong with the
conversion, and select all of them.
* (Upload and) select any additional icons that you want to use in the project, then click
**Download**.

### Updating the project
* Rename the font file in the archive downloaded earlier to `CustomIcons.ttf` and replace the
[custom font](assets/fonts/CustomIcons/CustomIcons.ttf) in the project.
* Copy the IconData definitions from the `.dart` file in the archive and replace the corresponding
definitions in the [`CustomIcons`](lib/resources/custom_icons.dart) class;
* Check that everything still works correctly :)

**Note**: [FontAwesome](https://fontawesome.com/icons?d=gallery) icons are recommended, where
possible, because they are consistent with the overall style. For additional action icons check out
[FontAwesomeActions](https://github.com/nyon/fontawesome-actions) - the repo provides an [`.svg`
font](https://github.com/nyon/fontawesome-actions/blob/master/dist/fonts/fontawesome-webfont.svg)
you can upload directly into [FlutterIcon](https://fluttericon.com/).
