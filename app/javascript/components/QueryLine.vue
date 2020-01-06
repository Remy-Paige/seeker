<template>
    <!--wrap in parent element to fix single root error-->
    <!--the update handler is one function as the emit event has all the information needed-->
    <!--[this.emitType, this.index, this.selectedElements]-->
    <div>
        <div class="query_line">
            <div class="label_select">
                <div v-if="option.label_select == 'label'" class="send_to_bottom_hack_label"></div>
                <div v-else class="send_to_bottom_hack"></div>
                <span class="query_label" v-if="option.label_select == 'label'">{{option.field}}</span>
                <autocomplete-dropdown
                        v-else
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        emitType="field"
                        :options="fieldOptions"
                        v-model="selectedfield"
                        placeholder="Select a field"
                ></autocomplete-dropdown>
            </div>
            <div class="filter_options">
                <div class="send_to_bottom_hack"></div>
                <autocomplete-dropdown
                        v-if="selectedfield == 'Year' || selectedfield == 'Cycle'"
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        :field="this.option.field"
                        value="all"
                        emitType="filter"
                        :options="filterOptions.numeric"
                        v-model="selectedFilter"
                        placeholder="Enter a filter type"
                ></autocomplete-dropdown>
                <autocomplete-dropdown
                        v-else
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        :field="this.option.field"
                        value="includes"
                        emitType="filter"
                        :options="filterOptions.inex"
                        v-model="selectedFilter"
                        placeholder="Enter a filter type"
                ></autocomplete-dropdown>
            </div>
            <div class="input">
                <div v-if="this.option.field == 'Country'">
                    <p class="help-text" v-if="this.option.filter == 'includes'">Select countries to include in search results</p>
                    <p class="help-text" v-else>Select countries to exclude from search results</p>
                    <pill-selector
                            class="width_100"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="country_pill"
                            :elements="countries"
                            placeholder="Select"
                    ></pill-selector>
                </div>
                <div v-else-if="this.option.field == 'Language'">
                    <p class="help-text" v-if="this.option.filter == 'includes'">Select languages to include in search results</p>
                    <p class="help-text" v-else>Select languages to exclude from search results</p>
                    <pill-selector
                            class="width_100"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="language_pill"
                            :elements="languages"
                            placeholder="Select"
                    ></pill-selector>
                </div>
                <div v-else-if="this.option.field == 'Report Type'">
                    <p class="help-text" v-if="this.option.filter == 'includes'">Select report types to include in search results</p>
                    <p class="help-text" v-else>Select report types to exclude from search results</p>
                    <pill-selector
                            class="width_100"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="report_type_pill"
                            :elements="report_types"
                            placeholder="Select"
                    ></pill-selector>
                </div>
                <div v-else-if="this.option.field == 'Section Text'">
                    <p class="help-text" v-if="this.option.filter == 'includes'">Include sections that match a word or phrase in results</p>
                    <p class="help-text" v-else>Exclude sections that match a word or phrase from results</p>
                    <query-text
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            :field="this.option.field"
                            emitType="section_text"
                            placeholder="this has been satisfactorily fulfilled"
                    ></query-text>
                </div>
                <div v-else-if="this.option.field == 'Article'">
                    <p class="help-text" v-if="this.option.filter == 'includes'">Separate articles to include with commas</p>
                    <p class="help-text" v-else>Separate articles to exclude with commas</p>
                    <query-text
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            :field="this.option.field"
                            emitType="article"
                            placeholder="7.1, 9.11, 8.2.b"
                    ></query-text>
                </div>
                <div v-else-if="this.option.field == 'Section Number'">
                    <p class="help-text" v-if="this.option.filter == 'includes'">Separate section or chapter numbers to include with commas</p>
                    <p class="help-text" v-else>Separate section or chapter numbers to exclude with commas</p>
                    <query-text
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            :field="this.option.field"
                            emitType="section_number"
                            placeholder="1.5, 2.3"
                    ></query-text>
                </div>
                <div v-else-if="this.option.field == 'Year'">
                    <p class="help-text" v-if="this.option.filter == 'only'">Include documents only from selected year</p>
                    <p class="help-text" v-else-if="this.option.filter == 'less than'">Include documents released before selected year</p>
                    <p class="help-text" v-else-if="this.option.filter == 'greater than'">Include documents released after selected year</p>
                    <p class="help-text" v-else-if="this.option.filter == 'between'">Include documents released between selected years</p>
                    <numeric
                            class="width_100"
                            :filter="this.option.filter"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="year"
                            placeholder="YYYY"
                    ></numeric>
                </div>
                <div v-else-if="this.option.field == 'Cycle'">
                    <p class="help-text" v-if="this.option.filter == 'only'">Include documents only from selected cycle</p>
                    <p class="help-text" v-else-if="this.option.filter == 'less than'">Include documents released before selected cycle</p>
                    <p class="help-text" v-else-if="this.option.filter == 'greater than'">Include documents released after selected cycle</p>
                    <p class="help-text" v-else-if="this.option.filter == 'between'">Include documents released between selected cycle</p>
                    <numeric
                            class="width_100"
                            :filter="this.option.filter"
                            v-on:updateQueryLine="updateMe"
                            :index="this.index"
                            emitType="cycle"
                            placeholder="2"
                    ></numeric>
                </div>
                <div v-else></div>
            </div>
            <div class="gap"></div>
        </div>
        <div class="break-and-align"></div>
    </div>
</template>

<script>
    import AutocompleteDropdown from '../components/AutocompleteDropdown'
    import PillSelector from '../components/PillSelector.vue'
    import QueryText from '../components/QueryText.vue'
    import Numeric from '../components/Numeric.vue'
    import EventBus from '../packs/event-bus.js';
    export default {
        props: {
            index: {
                type: String,
                required: true
            },
            option: {
                type: Object,
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
                //v-model this, matches search text prop
                selectedfield: this.option.field,
                selectedFilter: '',
                componentKey: 0,
                input:'',
                //dropdown options
                fieldOptions: {
                    'Country':'Country',
                    'Language':'Language',
                    'Section Text':'Section Text',
                    'Article':'Article',
                    'Section Number':'Section Number',
                    'Report Type':'Report Type',
                    'Year':'Year',
                    'Cycle':'Cycle'
                },
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
            updateMe: function (emit_payload) {
            //    emit types:field filter country langauage report type section text article section number year cycle
            //    options object :{
            //         "label_select": 'select',
            //         "field": 'Article',
            //         "filter": 'includes',
            //         "keywords": []
            // }
            //
                var type = emit_payload[0]
                var index = emit_payload[1]
                var input = emit_payload[2]

                if(type === 'field'){
                    this.option.field = input
                    this.$emit('updateRoot', [index, this.option])

                } else if (type === 'filter') {
                    this.option.filter = input
                    this.$emit('updateRoot', [index, this.option])
                } else {
                    console.log(input)
                    this.option.keywords = input
                    this.$emit('updateRoot', [index, this.option])
                }
            }
        },
        components: {
            'autocomplete-dropdown': AutocompleteDropdown,
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

    .query_select {
        width: 150px;
    }


</style>

