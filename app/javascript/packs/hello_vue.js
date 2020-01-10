/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.



import Vue from 'vue/dist/vue.esm'
// import TurbolinksAdapter from 'vue-turbolinks'
import VueResource from 'vue-resource'
import BootstrapVue from 'bootstrap-vue'
import Vuelidate from 'vuelidate'
import Vuex from 'vuex';


import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import App from '../components/app.vue'
import AutocompleteDropdown from '../components/AutocompleteDropdownFilter.vue'
import QueryLine from '../components/QueryLine.vue'

Vue.use(Vuelidate);
Vue.use(Vuex);
Vue.use(VueResource);
Vue.use(BootstrapVue);

import { mapState } from 'vuex';
console.log("hello from load");

document.addEventListener('DOMContentLoaded', () => {
    console.log("hello from DOM");
    //get csrf token
    //submit as part of ajax
    var nav =   new Vue({
        el: '#nav',
        data() {
            return {
                name: 'BootstrapVue',
                show: true
            }
        },
        watch: {
            show(newVal) {
                console.log('Alert is now ' + (newVal ? 'visible' : 'hidden'))
            }
        },
        methods: {
            toggle() {
                console.log('Toggle button clicked')
                this.show = !this.show
            },
            dismissed() {
                console.log('Alert dismissed')
            }
        }
    })
    var djwdoij =   new Vue({
        el: '#table_contents_element',
        data() {
            return {
                name: 'BootstrapVue',
                show: true
            }
        },
        watch: {
            show(newVal) {
                console.log('Alert is now ' + (newVal ? 'visible' : 'hidden'))
            }
        },
        methods: {
            toggle() {
                console.log('Toggle button clicked')
                this.show = !this.show
            },
            dismissed() {
                console.log('Alert dismissed')
            }
        }
    })
    var table_contents_element = document.getElementById("table_of_contents");
    if (table_contents_element != null ) {
        var table_contents_element =   new Vue({
            el: '#table_contents_element',
            data() {
                return {
                    name: 'BootstrapVue',
                    show: true
                }
            }
        })
    }
    var list = document.getElementsByClassName("save_section");
    if (list != null) {
        for (let item of list) {
            new Vue({
                el: '#' + item.id.toString(),
                data() {
                    return {
                        name: 'BootstrapVue',
                        show: true
                    }
                }
            })
        }
    }
    var save_query_element = document.getElementById("save_query_element_0");
    if (save_query_element != null ) {
        new Vue({
            el: '#save_query_element_0',
            data() {
                return {
                    name: 'BootstrapVue',
                    show: true
                }
            }
        })
    }
    var liiist = document.getElementsByClassName("show_more");
    if (liiist != null) {
        for (let item of liiist) {
            new Vue({
                el: '#' + item.id.toString(),
                data() {
                    return {
                        name: 'BootstrapVue',
                        show: true,
                        seen: false
                    }
                }
            })
        }
    }


    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var search_element = document.getElementById("search-form");

    if (search_element != null ) {

        //from the div - set up the JSON
        var query = JSON.parse(search_element.dataset.query);
        var languages = JSON.parse(search_element.dataset.languages);
        var countries = JSON.parse(search_element.dataset.countries);
        var report_types = JSON.parse(search_element.dataset.reportTypes);

        const store = new Vuex.Store({
            state: {
                message: 'Hello Vuex',
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
                query: {
                    id: null,
                    options: [{
                        label_select: 'label',
                        field: 'Article',
                        filter: 'includes',
                        keywords: []
                    },{
                        label_select: 'label',
                        field: 'Language',
                        filter: 'includes',
                        keywords: []
                    }, {
                        label_select: 'label',
                        field: 'Country',
                        filter: 'includes',
                        keywords: []
                    }]
                }
            },
            mutations: {
                updateMessage (state, message) {
                    state.message = message
                },
                updateQuery (state, {query}) {
                    state.query = query
                },
                removeLineFromQuery (state, {index}) {
                    state.query.options.splice(index, 1)
                },
                updateFieldByIndex (state, {index, value}) {
                    state.query.options[index].field = value
                    state.query.options[index].keywords = []
                },
                updateFilterByIndex (state, {index, value}) {
                    state.query.options[index].filter = value
                },
                updateKeywordsByIndex (state, {index, value}) {
                    state.query.options[index].keywords = value
                },
                removeOptionFromFieldOptions (state, {field}) {
                    delete state.fieldOptions[field]
                },
                addOptionToFieldOptions (state, {field}) {
                    state.fieldOptions[field] = field
                },
            },
            getters: {
                getQuery: state => {
                    return state.query
                },
                getFieldOptions: state => {
                    return state.fieldOptions
                },
                getOptionsByIndex: (state) => (index) => {
                    return state.query.options[index]
                },
                getLabelSelectByIndex: (state) => (index) => {
                    return state.query.options[index].label_select
                },
                getFieldByIndex: (state) => (index) => {
                    return state.query.options[index].field
                },
                getFilterByIndex: (state) => (index) => {
                    return state.query.options[index].filter
                },
                getKeywordsByIndex: (state) => (index) => {
                    return state.query.options[index].keywords
                }
            }
        });

        const app = new Vue({
            el: search_element,
            store,
            data: function () {
                return {
                    query: query,
                    languages: languages,
                    countries: countries,
                    report_types: report_types
                }
            },
            methods: {
                submitToSearch() {
                    var query_string = JSON.stringify(this.query);
                    window.location='/submit_search?query='+query_string;
                },
                addQueryLine(){
                    this.query.options.push({
                        "label_select": 'select',
                            "field": '',
                            "filter": '',
                            "keywords": []
                    })
                    this.$store.commit('updateQuery', {query: this.query})
                }
            },
            created(){
                this.$store.commit('updateQuery', {query: this.query})
            },
            mounted() {
                for (var option in this.query.options) {
                    console.log(this.query.options[option].field)
                    this.$store.commit('removeOptionFromFieldOptions', {field: this.query.options[option].field})
                }

            },
            computed: {
                options: {
                    get() {
                        return this.$store.getters.getFieldOptions
                    }
                },
                storeQuery: {
                    get() {
                        return this.$store.getters.getQuery
                    }
                }
            },
            watch: {
                storeQuery: function (newValue) {
                    this.query = newValue
                },
            },
            components: {
                'query-line' : QueryLine
            }
        })
    }

});

// document.addEventListener('turbolinks:load', () => {
//   console.log("hello from vue");
//
//   const app = new Vue({
//     el: '#hello',
//     mixins: [TurbolinksAdapter],
//     render: h => h(App)
//   })
// });


//todo:
// in pill selector and dropdown, add this watch if we want them to be able to type the whole thing and click away
// searchText: function (newValue) {
//     this.$emit('does this work')
// }