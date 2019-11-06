<!--https://www.designhammer.com/blog/reusable-vuejs-components-part-3-autocomplete-dropdown-->

<template>
    <div class="dropdown" :class="{'open' : open}">
        <input type="text"
               ref="search"
               :placeholder="placeholder"
               v-model="searchText"
               @input="searchChanged"
               @mousedown.prevent
               @click="setOpen(!open)"
               @keydown.enter="suggestionSelected(matches[highlightIndex])"
               @keydown.down="down"
               @keydown.up="up"
               @keydown.esc="setOpen(false)"
               @blur="setOpen(false)"
        ><a class="toggle" @mousedown.prevent @click="setOpen(!open)">
        <span class="arrow-up">▲</span>
        <span class="arrow-down">▼</span>
    </a>
        <ul class="suggestion-list">
            <li v-for="(suggestion, index) in matches"
                :class="{'active' : index === highlightIndex}"
                @mousedown.prevent
                @click="suggestionSelected(suggestion)"
            >
                {{ suggestion[0] }}
            </li>
        </ul>
    </div>
</template>

<script>
    export default {
        props: {
            index: {
                type: String,
                required: true
            },
            value: null,
            emitType: {
                type: String,
                required: true
            },
            options: {
                type: Object,
                required: true
            },
            placeholder: {
                type: String,
                default: 'Enter an item name to search'
            }
        },
        data: function () {
            return {
                searchText: '',
                selectedOption: null,
                open: false,
                highlightIndex: 0,
                lastSearchText: ''
            }
        },
        methods: {
            setOpen (isOpen) {
                this.open = isOpen

                if (this.open) {
                    this.$refs.search.focus()
                    this.lastSearchText = this.searchText
                    this.searchText = ''
                } else if (this.searchText.trim() === '') {
                    this.searchText = this.lastSearchText
                }
            },
            searchChanged () {
                if (!this.open) {
                    this.open = true
                }
            },
            suggestionSelected (suggestion) {
                this.open = false
                this.searchText = suggestion[0]
                this.$emit('updateQueryLine', [this.emitType, this.index, this.selectedElements])
                this.$emit('input', suggestion[1])
            },
            updateComponentWithValue(newValue) {
                if (Object.values(this.options).indexOf(newValue) > -1) {
                    // Find the matching text for the supplied option value
                    for (var text in this.options) {
                        if (this.options.hasOwnProperty(text)) {
                            if (this.options[text] === newValue) {
                                this.searchText = text
                            }
                        }
                    }
                }
            },
            up () {
                if (this.open) {
                    if (this.highlightIndex > 0) {
                        this.highlightIndex--
                    }
                } else {
                    this.setOpen(true)
                }
            },
            down () {
                if (this.open) {
                    if (this.highlightIndex < this.matches.length - 1) {
                        this.highlightIndex++
                    }
                } else {
                    this.setOpen(true)
                }
            },
            searchChanged () {
                if (!this.open) {
                    this.open = true
                }

                this.highlightIndex = 0
            }
        },
        mounted () {
            //theres a better way to load i nthese default values but the prop wasnt working so whatever
            if (this.index <3) {
                this.updateComponentWithValue('includes')
            } else {
                this.updateComponentWithValue(this.value)
            }
        },
        watch: {
            value: function (newValue) {
                this.updateComponentWithValue(newValue)
            },
            // searchText: function (newValue) { if we want them to be able to type the whole thing
            //     this.$emit('does this work')
            // }
        },
        computed: {
            matches () {
                return Object.entries(this.options).filter((option) => {
                    var optionText = option[0].toUpperCase()
                    return optionText.match(this.searchText.toUpperCase().replace(/\s+/g, '.+'))
                })
            }
        }
    }
</script>

<style scoped>

  /*<!--fix to be variable-->*/
  input {
      width: 150px;
  }
  .dropdown {
      display: inline-block;
      position: relative;
  }

  .suggestion-list {
      background-color: rgba(255, 255, 255, 0.95);
      border: 1px solid #ddd;
      list-style: none;
      display: block;
      margin: 0;
      padding: 0;
      width: 100%;
      overflow: hidden;
      position: absolute;
      top: 32px;
      left: 0;
      z-index: 2;
  }
  .toggle {
      position: relative;
      right: 25px;
  }
  .toggle:hover {
      color: black;
      background-color: transparent;
      text-decoration: none;
  }
  .dropdown.open .suggestion-list {
      display: block;
  }

  .dropdown .suggestion-list {
      display: none;
  }
  .toggle .arrow-up {
      display: none;
  }

  .open .toggle .arrow-up {
      display: inline-block;
  }

  .open .toggle .arrow-down {
      display: none;
  }

  .suggestion-list li {
      cursor: pointer;
  }

  .suggestion-list li:hover {
      color: #fff;
      background-color: #ccc;
  }

  .active  {
      color: #fff;
      background-color: #42b983;
  }
</style>
