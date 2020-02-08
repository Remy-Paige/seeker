<template>
    <!--wrap in parent element to fix single root error-->
    <!--the update handler is one function as the emit event has all the information needed-->
    <!--[this.emitType, this.index, this.selectedElements]-->
    <div>
        <div class="query_line" v-bind:class="{ line_error: error }">
            <div class="label_select">
                <div v-if="labelSelect == 'label'" class="send_to_bottom_hack_label"></div>
                <div v-else class="send_to_bottom_hack"></div>
                <span class="query_label" v-if="labelSelect === 'label'">{{selectedField}}</span>
                <autocomplete-dropdown-field
                        v-else
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        emitType="field"
                        v-model="selectedField"
                        placeholder="Select a field"
                ></autocomplete-dropdown-field>
            </div>
            <div class="filter_options">
                <div class="send_to_bottom_hack"></div>
                <autocomplete-dropdown-filter
                        v-if="selectedField === 'Year' || selectedField === 'Cycle'"
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        :field="selectedField"
                        value="all"
                        emitType="filter"
                        :options="filterOptions.numeric"
                        v-model="selectedFilter"
                        placeholder="Enter a filter type"
                ></autocomplete-dropdown-filter>
                <autocomplete-dropdown-filter
                        v-else
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        :field="selectedField"
                        value="includes"
                        emitType="filter"
                        :options="filterOptions.inex"
                        v-model="selectedFilter"
                        placeholder="Enter a filter type"
                ></autocomplete-dropdown-filter>
            </div>
            <div class="input">
                <div v-if="selectedField == 'Country'">
                    <p class="help-text" v-bind:class="{ text_error: error }" v-if="selectedFilter == ''">Select a filter</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'includes'">Select countries to include in search results</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else>Select countries to exclude from search results</p>
                    <pill-selector
                            class="width_100"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="country_pill"
                            :elements="countries"
                            placeholder="Select"
                    ></pill-selector>
                </div>
                <div v-else-if="selectedField == 'Language'">
                    <p class="help-text" v-bind:class="{ text_error: error }" v-if="selectedFilter == ''">Select a filter</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'includes'">Select languages to include in search results</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else>Select languages to exclude from search results</p>
                    <pill-selector
                            class="width_100"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="language_pill"
                            :elements="languages"
                            placeholder="Select"
                    ></pill-selector>
                </div>
                <div v-else-if="selectedField == 'Report Type'">
                    <p class="help-text" v-bind:class="{ text_error: error }" v-if="selectedFilter == ''">Select a filter</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'includes'">Select report types to include in search results</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else>Select report types to exclude from search results</p>
                    <pill-selector
                            class="width_100"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="report_type_pill"
                            :elements="report_types"
                            placeholder="Select"
                    ></pill-selector>
                </div>
                <div v-else-if="selectedField == 'Section Text'">
                    <p class="help-text" v-bind:class="{ text_error: error }" v-if="selectedFilter == ''">Select a filter</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'includes'">Include sections that match a word or phrase in results</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else>Exclude sections that match a word or phrase from results</p>
                    <query-text
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            :field="selectedField"
                            emitType="section_text"
                            placeholder="this has been satisfactorily fulfilled"
                    ></query-text>
                </div>
                <div v-else-if="selectedField == 'Article'">
                    <p class="help-text" v-bind:class="{ text_error: error }" v-if="selectedFilter == ''">Select a filter</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'includes'">Separate articles to include with spaces</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else>Separate articles to exclude with commas</p>
                    <query-text
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            :field="selectedField"
                            emitType="article"
                            placeholder="7.1, 9.11, 8.2.b"
                    ></query-text>
                </div>
                <div v-else-if="selectedField == 'Section Number'">
                    <p class="help-text" v-bind:class="{ text_error: error }" v-if="selectedFilter == ''">Select a filter</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'includes'">Separate section or chapter numbers to include with spaces</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else>Separate section or chapter numbers to exclude with commas</p>
                    <query-text
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            :field="selectedField"
                            emitType="section_number"
                            placeholder="1.5, 2.3"
                    ></query-text>
                </div>
                <div v-else-if="selectedField == 'Year'">
                    <p class="help-text" v-bind:class="{ text_error: error }" v-if="selectedFilter == ''">Select a filter</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'only'">Include documents only from selected year</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'less than'">Include documents released before selected year</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'greater than'">Include documents released after selected year</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'between'">Include documents released between selected years</p>
                    <numeric
                            class="width_100"
                            :filter="selectedFilter"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="year"
                            placeholder="YYYY"
                    ></numeric>
                </div>
                <div v-else-if="selectedField == 'Cycle'">
                    <p class="help-text" v-bind:class="{ text_error: error }" v-if="selectedFilter == ''">Select a filter</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'only'">Include documents only from selected cycle</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'less than'">Include documents released before selected cycle</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'greater than'">Include documents released after selected cycle</p>
                    <p class="help-text" v-bind:class="{ text_error: error }" v-else-if="selectedFilter == 'between'">Include documents released between selected cycle</p>
                    <numeric
                            class="width_100"
                            :filter="selectedFilter"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="cycle"
                            placeholder="2"
                    ></numeric>
                </div>
                <div v-else></div>
            </div>
            <div class="gap">
                <div class="size" v-if="this.index > 2" v-on:click="removeQueryLine"> <span class="remove_filter_label" v-bind:class="{ text_error: error }" >Remove Filter</span></div>
            </div>
        </div>
        <div class="break-and-align"></div>
    </div>
</template>

<script>
    import AutocompleteDropdownField from './AutocompleteDropdownField'
    import AutocompleteDropdownFilter from './AutocompleteDropdownFilter'
    import PillSelector from '../components/PillSelector.vue'
    import QueryText from '../components/QueryText.vue'
    import Numeric from '../components/Numeric.vue'
    export default {
        props: {
            index: {
                type: String,
                required: true
            },
            languages: {
                type: Object,
                required: true
            },
            countries: {
                type: Object,
                required: true
            },
            report_types: {
                type: Object,
                required: true
            }
        },
        data: function () {
            return {
                filterOptions: {
                    'inex': {
                        'includes':'includes',
                        'excludes':'excludes'
                    },
                    'numeric': {
                        'only':'only',
                        'less than':'less than',
                        'greater than':'greater than',
                        'between':'between'
                    }
                }

            }
        },
        methods: {
            updateMe() {

            },
            removeQueryLine(){
                this.$store.commit('addOptionToFieldOptions', {field: this.$store.getters.getFieldByIndex(this.index)})
                this.$store.commit('removeLineFromQuery', {index: this.index})
            }
        },
        computed: {
            error () {
                var error = this.$store.getters.getErrorByIndex(this.index)
                if (error === true) {
                    return true
                } else {
                    return false
                }
            },
            selectedField: {
                get () {
                    return this.$store.getters.getFieldByIndex(this.index)
                },
                set (value) {
                    this.$store.commit('updateFieldByIndex', {index: this.index, value: value})
                }
            },
            selectedFilter: {
                get () {
                    return this.$store.getters.getFilterByIndex(this.index)
                },
                set (value) {
                    this.$store.commit('updateFilterByIndex', {index: this.index, value: value})
                }
            },
            labelSelect: {
                get () {
                    return this.$store.getters.getLabelSelectByIndex(this.index)
                }
            },
            fieldOptions: {
                get () {
                    return this.$store.getters.getFieldOptions
                }
            }
        },
        components: {
            'autocomplete-dropdown-field': AutocompleteDropdownField,
            'autocomplete-dropdown-filter': AutocompleteDropdownFilter,
            'pill-selector': PillSelector,
            'query-text': QueryText,
            'numeric': Numeric
        }
    }
</script>

<style scoped>

    .send_to_bottom_hack {
        height: 18px;
    }

    .send_to_bottom_hack_label {
        height: 12px;
    }

    .width_100 {
        width: 100%;
    }

    .help-text {
        font-size: x-small;
        color: #757575;
        margin: 0;
    }

    .query_label {
        font-size: 27px;
    }

    .query_line {
        margin-bottom: 0;
        display: grid;
        grid-template-columns: 3fr 4fr 8fr 50px;
    }
    .break-and-align {
        height: 15px;
    }
    .remove_filter_label {
        font-size: 15px;
        color: #6c6c6a;
        cursor: default;
    }
    .size {
        width: 103px;
        position: relative;
        right: 100px;
        top: 19px;
    }
    .query_select {
        width: 150px;
    }
    .line_error {
        background-color: #dc2c25;
        border-radius: 0.25rem;
        padding: 5px;
    }
    .text_error {
        color: white !important;
    }


</style>

