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


import QueryLine from '../components/QueryLine.vue'

Vue.use(Vuelidate);
Vue.use(Vuex);
Vue.use(VueResource);
Vue.use(BootstrapVue);

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
                show: true,
                localShow: true,
                showDismissibleAlert: true
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
    DismissibleAlert
    var DismissibleAlert =   new Vue({
        el: '#DismissibleAlert',
        data() {
            return {
                name: 'BootstrapVue',
                show: true
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
                    error: false,
                    keywords: []
                },{
                    label_select: 'label',
                    field: 'Language',
                    filter: 'includes',
                    error: false,
                    keywords: []
                }, {
                    label_select: 'label',
                    field: 'Country',
                    filter: 'includes',
                    error: false,
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
            updateErrorByIndex (state, {index, value}) {
                state.query.options[index].error = value
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
            getQueryString: state => {
                return JSON.stringify({query: state.query})
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
            getErrorByIndex: (state) => (index) => {
                return state.query.options[index].error
            },
            getKeywordsByIndex: (state) => (index) => {
                return state.query.options[index].keywords
            }
        }
    });
    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')


    //home/advanced_search
    var search_element = document.getElementById("search-form");
    if (search_element != null ) {

        //from the div - set up the JSON
        var query = JSON.parse(search_element.dataset.query);
        var languages = JSON.parse(search_element.dataset.languages);
        var countries = JSON.parse(search_element.dataset.countries);
        var report_types = JSON.parse(search_element.dataset.reportTypes);
        var errors = JSON.parse(search_element.dataset.errors);

        const app = new Vue({
            el: search_element,
            store,
            data: function () {
                return {
                    query: query,
                    languages: languages,
                    countries: countries,
                    report_types: report_types,
                    errors: errors
                }
            },
            methods: {
                submitToSearch() {
                    this.errors = []
                    for (var x = 0; x < this.query.options.length; x++) {
                        this.$store.commit('updateErrorByIndex', {index: x, value: false})
                    }
                    var query_string = JSON.stringify(this.query);
                    console.log(query_string)
                    for (var i = 0; i < this.query.options.length; i++) {
                        console.log(this.query.options[i].field);
                        if (this.query.options[i].field === '') {
                            console.log('error')
                            this.$store.commit('updateErrorByIndex', {index: i, value: true})
                            this.errors.push('Select a field on line ' + (i+1).toString())
                        }
                        if (this.query.options[i].filter === '') {
                            console.log('error')
                            this.$store.commit('updateErrorByIndex', {index: i, value: true})
                            this.errors.push('Select a filter on line ' + (i+1).toString())
                        }
                        if (this.query.options[i].field === 'Year') {
                            if (this.query.options[i].filter === 'between') {
                                console.log(this.query.options[i].keywords);
                                if (this.query.options[i].keywords[0] === '' || parseInt(this.query.options[i].keywords[0]) < 1900 || isNaN(this.query.options[i].keywords[0]) || this.query.options[i].keywords[1] === '' || parseInt(this.query.options[i].keywords[1]) < 1900 || isNaN(this.query.options[i].keywords[1])) {
                                    console.log('error')
                                    this.$store.commit('updateErrorByIndex', {index: i, value: true})
                                    this.errors.push('Year field must be a 4 digit number above 1900')
                                }
                            }
                            else {
                                console.log('other filter')
                                if (this.query.options[i].keywords[0] === '' || parseInt(this.query.options[i].keywords[0]) < 1900 || isNaN(this.query.options[i].keywords[0])) {
                                    console.log(this.query.options[i].keywords)
                                    console.log('error')
                                    this.$store.commit('updateErrorByIndex', {index: i, value: true})
                                    this.errors.push('Year field must be a 4 digit number above 1900')
                                }
                            }
                        }
                        if (this.query.options[i].field === 'Cycle') {
                            if (this.query.options[i].filter === 'between') {
                                console.log(this.query.options[i].keywords);
                                if (this.query.options[i].keywords[0] === '' || parseInt(this.query.options[i].keywords[0]) > 99 || isNaN(this.query.options[i].keywords[0]) || this.query.options[i].keywords[1] === '' || parseInt(this.query.options[i].keywords[1]) > 99 || isNaN(this.query.options[i].keywords[1])) {
                                    console.log('error')
                                    this.$store.commit('updateErrorByIndex', {index: i, value: true})
                                    this.errors.push('Cycle field must be a 1 or 2 digit number')
                                }
                            }
                            else {
                                console.log('other filter')
                                if (this.query.options[i].keywords[0] === '' || parseInt(this.query.options[i].keywords[0]) > 99 || isNaN(this.query.options[i].keywords[0])) {
                                    console.log(this.query.options[i].keywords)
                                    console.log('error')
                                    this.$store.commit('updateErrorByIndex', {index: i, value: true})
                                    this.errors.push('Cycle field must be a 1 or 2 digit number')
                                }
                            }
                        }
                        console.log('this.query.options[i].field === \'Section Text\'')
                        console.log(this.query.options[i].field === 'Section Text')
                        console.log('this.query.options[i].keywords.length === 0')
                        console.log(this.query.options[i].keywords.length === 0)
                        if (this.query.options[i].field === 'Section Text') {
                            console.log('TEXT')
                            console.log(this.query.options[i].keywords)
                            if (this.query.options[i].keywords === '' || this.query.options[i].keywords.length === 0 ) {
                                console.log('error')
                                this.$store.commit('updateErrorByIndex', {index: i, value: true})
                                this.errors.push('Section Text field is blank. Add text or remove filter')
                            }
                        }
                        if (this.query.options[i].field === 'Section Number' || this.query.options[i].field === 'Article') {
                            for (var z = 0; z < this.query.options[i].keywords.length; z++) {
                                var match = this.query.options[i].keywords[z].match(/[0-9]*$|[0-9]*\.[0-9]*$|[0-9]*\.[0-9]\.[a-z]*$/)
                                console.log(match)
                                if (match[0] !== this.query.options[i].keywords[z]) {
                                    console.log('error')
                                    this.$store.commit('updateErrorByIndex', {index: i, value: true})
                                    this.errors.push(this.query.options[i].field + 's must be in the form number, number.number or number.number.letter and separated with spaces')
                                }
                            }
                        }
                    }
                    if (this.errors.length === 0) {
                        window.location='/submit_search?query='+query_string;
                    }
                },
                addQueryLine(){
                    this.query.options.push({
                        "label_select": 'select',
                            "field": '',
                            "filter": '',
                            "error": false,
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