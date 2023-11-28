# Tabula

Simple staticaly-generated site with boards, lists and cards.

## MVP Description

- single board supported
- one Markdown file per card
- relations between cards and lists stored in Yaml file
- script to generate static HTML from MD+YML files
- script to import data from Trello (parsing exported JSONs)

## Custom Markdown Syntax

### Check Lists / Task Lists

Tabula uses checklists (aka Task List from GFM):

```markdown
- [x] Step 1
- [x] Step 2
- [ ] Profit
```

which is converted to

```HTML
<ul>
  <li><input checked="" disabled="" type="checkbox"> Step 1</li>
  <li><input checked="" disabled="" type="checkbox"> Step 2</li>
  <li><input disabled="" type="checkbox"> Step 3</li>
</ul>
```

### Description Lists

Tabula uses AsciiDoc-style description lists:

```markdown
Platform:: PS5
Release:: 2023-01-27
Publisher:: Electronic Arts Inc
Genre:: Horror
```

which is converted to

```HTML
<dl>
  <dt>Platform</dt>
  <dd>PS5</dd>
  <dt>Release</dt>
  <dd>2023-01-27</dd>
  <dt>Publisher</dt>
  <dd>Electronic Arts Inc</dd>
  <dt>Genre</dt>
  <dd>Horror</dd>
</dl>
```
