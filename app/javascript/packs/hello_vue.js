/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.
// All it does is render <div>Hello Vue</div> at the bottom of the page.



import Vue from 'vue/dist/vue.esm'
// import TurbolinksAdapter from 'vue-turbolinks'
import VueResource from 'vue-resource'
import App from '../components/app.vue'
import AutocompleteDropdown from '../components/AutocompleteDropdown'
import QueryLine from '../components/QueryLine.vue'

Vue.use(VueResource)
console.log("hello from load");

document.addEventListener('DOMContentLoaded', () => {
    console.log("hello from DOM");
    //get csrf token
    //submit as part of ajax

    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var search_element = document.getElementById("search-form");

    if (search_element != null ) {

        //from the div - set up the JSON
        var query = JSON.parse(search_element.dataset.query);
        var languages = JSON.parse(search_element.dataset.languages);
        var countries = JSON.parse(search_element.dataset.countries);
        var report_types = JSON.parse(search_element.dataset.reportTypes);

        console.log(query);

        const app = new Vue({
            el: search_element,
            data: function () {
                return {
                    query: query,
                    languages: languages,
                    countries: countries,
                    report_types: report_types
                }
            },
            methods: {
                updateRoot: function (emit_payload) {
                    var index = emit_payload[0]
                    var new_option = emit_payload[1]
                    this.query.options[index] = new_option
                },
                submitToSearch() {
                    var query_string = JSON.stringify(this.query);
                    window.location='/submit_search?query='+query_string;
                //     this.$http.get('/submit_search', {query: this.query}).then(response => {
                //     //success
                //     console.log(response)
                // }, response => {
                //     //fails
                //     console.log(response)
                // })
                },
                saveQuery() {

                }
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