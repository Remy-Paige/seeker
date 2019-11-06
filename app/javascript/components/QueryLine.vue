<template>
    <!--wrap in parent element to fix single root error-->
    <!--the update handler is one function as the emit event has all the information needed-->
    <!--[this.emitType, this.index, this.selectedElements]-->
    <div class="query_line">
        <div class="label_select">
            <label class="query_label" v-if="option.label_select == 'label'">{{option.field}}</label>
            <autocomplete-dropdown
                    v-else
                    :index="this.index"
                    emitType="field"
                    :options="fieldOptions"
                    v-model="selectedfield"
                    placeholder="Select a field"
            ></autocomplete-dropdown>
        </div>
        <div class="filter_options">
            <autocomplete-dropdown
                    v-if="selectedfield == 'Year' || selectedfield == 'Cycle'"
                    :index="this.index"
                    value="all"
                    emitType="filter"
                    :options="filterOptions.numeric"
                    v-model="selectedFilter"
                    placeholder="Enter a filter type"
            ></autocomplete-dropdown>
            <autocomplete-dropdown
                    v-else
                    :index="this.index"
                    value="includes"
                    emitType="filter"
                    :options="filterOptions.inex"
                    v-model="selectedFilter"
                    placeholder="Enter a filter type"
            ></autocomplete-dropdown>
        </div>
        <div class="gap"></div>
        <div class="input">
            <div v-if="this.option.field == 'Country'">
                <h5 v-if="this.option.filter == 'includes'">Select countries to include in search results</h5>
                <h5 v-else>Select countries to exclude from search results</h5>
                <pill-selector
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        emitType="country_pill"
                        :elements="countries"
                        placeholder="Select"
                ></pill-selector>
            </div>
            <div v-else-if="this.option.field == 'Language'">
                <h5 v-if="this.option.filter == 'includes'">Select languages to include in search results</h5>
                <h5 v-else>Select languages to exclude from search results</h5>
                <pill-selector
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        emitType="language_pill"
                        :elements="languages"
                        placeholder="Select"
                ></pill-selector>
            </div>
            <div v-else-if="this.option.field == 'Report Type'">
                <h5 v-if="this.option.filter == 'includes'">Select report types to include in search results</h5>
                <h5 v-else>Select report types to exclude from search results</h5>
                <pill-selector
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        emitType="report_type_pill"
                        :elements="report_types"
                        placeholder="Select"
                ></pill-selector>
            </div>
            <div v-else-if="this.option.field == 'Section Text'">
                <h5 v-if="this.option.filter == 'includes'">Include sections that match a word or phrase in results</h5>
                <h5 v-else>Exclude sections that match a word or phrase from results</h5>
                <query-text
                        v-on:updateQueryLine="updateMe"
                        :index="this.index"
                        emitType="section_text"
                        placeholder="this has been satisfactorily fulfilled"
                ></query-text>
            </div>
            <div v-else-if="this.option.field == 'Article'">
                <h5 v-if="this.option.filter == 'includes'">Separate articles to include with commas</h5>
                <h5 v-else>Separate articles to exclude with commas</h5>
                <query-text
                        :index="this.index"
                        emitType="article"
                        placeholder="7.1, 9.11, 8.2.b"
                ></query-text>
            </div>
            <div v-else-if="this.option.field == 'Section Number'">
                <h5 v-if="this.option.filter == 'includes'">Separate section or chapter numbers to include with commas</h5>
                <h5 v-else>Separate section or chapter numbers to exclude with commas</h5>
                <query-text
                        :index="this.index"
                        emitType="section_number"
                        placeholder="1.5, 2.3"
                ></query-text>
            </div>
            <div v-else-if="this.option.field == 'Year'">
                <h5 v-if="this.option.filter == 'includes'">Select years to include</h5>
                <h5 v-else>Select years to exclude</h5>
                <numeric
                        :index="this.index"
                        emitType="year"
                        placeholder="YYYY"
                ></numeric>
            </div>
            <div v-else-if="this.option.field == 'Cycle'">
                <h5 v-if="this.option.filter == 'includes'">Select cycles to include</h5>
                <h5 v-else>Select cycles to exclude</h5>
                <numeric
                        :index="this.index"
                        emitType="cycle"
                        placeholder="2"
                ></numeric>
            </div>
            <div v-else></div>
        </div>
    </div>
</template>

<script>
    import AutocompleteDropdown from '../components/AutocompleteDropdown'
    import PillSelector from '../components/PillSelector.vue'
    import QueryText from '../components/QueryText.vue'
    import Numeric from '../components/Numeric.vue'
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
                        'all':'all',
                        'only':'only',
                        'less than':'less than',
                        'greater than':'greater than'
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

    .query_line {
        display: grid;
        grid-template-columns: 3fr 4fr 50px 8fr;
    }

    .query_select {
        width: 150px;
    }


</style>

