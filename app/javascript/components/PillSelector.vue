<template>
    <div>
        <div class="dropdown" :class="{'open' : open}">
            <input type="text"
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

        <div v-for="(item, index) in selectedElements">
            <div >
                {{item}}
                <button v-on:click="removeElement(item)">remove</button>
            </div>
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
        //2) select an element from the dropdown - click on suggestion or press enter in text box
        //  suggestion selected function - close dropdown, set text as suggestion, emit input event
        //3) input event and value prop watcher
        //  search changed and update component with value

        methods: {
            removeElement(item) {
                this.selectedElements.splice(this.selectedElements.indexOf(item), 1)
                this.$set(this.elements, item, item)
                this.element = 'a'
                this.element = ''
                this.$emit('updateQueryLine', [this.emitType, this.index, this.selectedElements])
            },
            //clear text,open the dropdown, focus on text input
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
            //when click or press enter on a dropdown
            //suggestion comes from matches comes from elements
            //both [0] and [1] are the same right now
            //emit - input triggers searchChanged (event watcher is in template)
            //change in value prop via element triggers updatecomponent with value
            suggestionSelected (suggestion) {
                this.open = false
                this.selectedElements.push(suggestion[0])
                delete this.elements[suggestion[0]]
                //hack to get the computed matches to change to update the dropdown
                this.element = 'a'
                this.element = ''
                this.$emit('updateQueryLine', [this.emitType, this.index, this.selectedElements])
                this.$emit('input', suggestion[1])
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
            searchChanged () {
                if (!this.open) {
                    this.open = true
                }

                this.highlightIndex = 0
            }
        },
        mounted () {
            this.updateComponentWithValue(this.value)
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
