<template>
    <div>
        <div class="auto_dropdown" :class="{'open' : open, 'width_100' : 'width_100'}" >
            <input type="text"
                   class="width_100_plus_toggle"
                   ref="search"
                   :placeholder="placeholder"
                   v-model="element"
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
            <ul class="suggestion-list width_100">
                <li v-for="(suggestion, index) in matches"
                    :class="{'active' : index === highlightIndex}"
                    @mousedown.prevent
                    @click="suggestionSelected(suggestion)"
                >
                    {{ suggestion[0] }}
                </li>
            </ul>
        </div>
        <div></div>
        <div class="width_100_plus_toggle">
            <span v-for="(item, index) in selectedElements" >
                <div class="">
                    {{item}}
                    <span v-on:click="removeElement(item)"><i class="fas fa-times-circle"></i></span>
                </div>
            </span>
        </div>
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
            elements: {
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
                element: '',
                selectedElements: [],
                open: false,
                highlightIndex: 0,
                lastElement: ''
            }
        },

        //1) click on box
        //  drop down is opened, focus on text input
        //1.5) click away at any time
        //  goes back to previously selected element (inc nothing)
        //2) select an element from the auto_dropdown - click on suggestion or press enter in text box
        //  suggestion selected function - close auto_dropdown, set text as suggestion, emit input event
        //3) input event and value prop watcher
        //  search changed and update component with value

        methods: {
            removeElement(item) {
                this.selectedElements.splice(this.selectedElements.indexOf(item), 1)
                this.$set(this.elements, item, item)
                this.element = 'a'
                this.element = ''
                this.$store.commit('updateKeywordsByIndex', {index: parseInt(this.index, 10), value: this.selectedElements})

            },
            addElement(item) {
                this.selectedElements.push(item[0])
                delete this.elements[item[0]]
                //hack to get the computed matches to change to update the auto_dropdown
                this.element = 'a'
                this.element = ''
                this.$store.commit('updateKeywordsByIndex', {index: parseInt(this.index, 10), value: this.selectedElements})
            },
            //clear text,open the auto_dropdown, focus on text input
            //or set text element as last element if click away
            setOpen (isOpen) {
                this.open = isOpen

                if (this.open) {
                    this.$refs.search.focus()
                    this.lastElement = this.element
                    this.element = ''
                } else if (this.element.trim() === '') {
                    this.element = this.lastElement
                }
            },
            //for keyboard navigation, set highlight to 0 if type
            searchChanged () {
                if (!this.open) {
                    this.open = true
                }
            },
            //when click or press enter on a auto_dropdown
            //suggestion comes from matches comes from elements
            //both [0] and [1] are the same right now
            //emit - input triggers searchChanged (event watcher is in template)
            //change in value prop via element triggers updatecomponent with value
            suggestionSelected (suggestion) {
                this.open = false
                this.addElement(suggestion)
            },

            //update our component’s state when a new value is provided
            //triggered on mount and when value prop is changed via element
            //We need to handle updating our component’s state when a new value is provided.
            //For the autocomplete this means setting the search field text to be the label text for the provided value.
            updateComponentWithValue(newValue) {
                //if text of element exists in the suggestions list
                if (Object.values(this.elements).indexOf(newValue) > -1) {
                    // Find the matching text for the supplied elements value
                    for (var text in this.elements) {
                        if (this.elements.hasOwnProperty(text)) {
                            if (this.elements[text] === newValue) {
                                this.element = ''
                            }
                        }
                    }
                }
            },
            //keyboard navigation
            up () {
                if (this.open) {
                    if (this.highlightIndex > 0) {
                        this.highlightIndex--
                    }
                } else {
                    this.setOpen(true)
                }
            },
            //keyboard navigation
            down () {
                if (this.open) {
                    if (this.highlightIndex < this.matches.length - 1) {
                        this.highlightIndex++
                    }
                } else {
                    this.setOpen(true)
                }
            },
            // searchChanged () {
            //     if (!this.open) {
            //         this.open = true
            //     }
            //
            //     this.highlightIndex = 0
            // }
        },
        mounted () {
            this.updateComponentWithValue(this.value)
            var keywords = this.$store.getters.getKeywordsByIndex(this.index)
            for (const element of keywords) {
                this.addElement([element,element])
            }
        },
        watch: {
            value: function (newValue) {
                this.updateComponentWithValue(newValue)
            }

        },
        computed: {
            matches () {
                return Object.entries(this.elements).filter((option) => {
                    var optionText = option[0].toUpperCase()
                    return optionText.match(this.element.toUpperCase().replace(/\s+/g, '.+'))
                }).sort(this.elements[0])
            },
            includes () {
                var filter = this.$store.getters.getFilterByIndex(this.index)
                if (filter === 'includes') {
                    return true
                }
            },
            excludes () {
                var filter = this.$store.getters.getFilterByIndex(this.index)
                if (filter === 'excludes') {
                    return true
                }
            }
        }
    }
</script>

<style scoped>

    input {
        padding-left: 5px;
        border: black 1px solid;
        border-radius: 3px;
    }
    .width_100 {
        width: 100%;
    }
    .width_10 {
        width: 5px;
        display: inline-block;
    }
    .auto_dropdown {
        display: inline-block;
        position: relative;
    }
    .red_pill {
        background-color: red;
    }
    .green_pill {
        background-color: green;
    }

    .pill {
        display: inline-block;
        border-radius: 10px;
        background-color: lightslategray;
        color: white;
        font-size: 13px;
        margin-left: 10px;
        margin-top: 5px;
        margin-bottom: 0px;
        padding-left: 5px;
        padding-right: 5px;
        padding-top: 1px;
        padding-bottom: 1px;
    }

    .suggestion-list {
        /*same as width with toggle*/
        width: 75%;
        background-color: rgba(255, 255, 255, 0.95);
        border: 1px solid #ddd;
        list-style: none;
        display: block;
        margin: 0;
        padding: 0;
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
    .auto_dropdown.open .suggestion-list {
        display: block;
    }

    .auto_dropdown .suggestion-list {
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
