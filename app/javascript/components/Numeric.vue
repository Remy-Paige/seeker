<template>
    <div>
        <div v-if="filter == 'between'">
            <input
                   class="half_width_100_plus_toggle"
                   type="text"
                   :placeholder="placeholder"
                   v-model="searchText1"
            >
            and
            <input
                   class="half_width_100_plus_toggle"
                   type="text"
                   :placeholder="placeholder"
                   v-model="searchText2"
            >

        </div>
        <div v-else>
            <input class="width_100_plus_toggle"
                    type="text"
                   :placeholder="placeholder"
                   v-model="searchText"
            >
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
            placeholder: {
                type: String,
                default: 'Enter an item name to search'
            }
        },
        data: function () {
            return {
                searchText: '',
                searchText1: '',
                searchText2: ''
            }
        },
        mounted () {
            var filter = this.$store.getters.getFilterByIndex(this.index)
            var keywords = this.$store.getters.getKeywordsByIndex(this.index)
            this.searchText1 = keywords[0]
            if (filter === 'between') {
                this.searchText2 = keywords[1]
            }
        },
        computed: {
            filter: {
                get () {
                    return this.$store.getters.getFilterByIndex(this.index)
                }
            }
        },
        watch: {
            searchText: function () {
                if(this.filter === 'between'){
                    this.$store.commit('updateKeywordsByIndex', {index: parseInt(this.index, 10), value: [this.searchText1, this.searchText2]})
                } else {
                    this.$store.commit('updateKeywordsByIndex', {index: parseInt(this.index, 10), value: [this.searchText]})
                }

            },
            filter: function() {
                if(this.filter === 'between'){
                    this.searchText1 = this.searchText;
                    this.searchText = '';
                } else {
                    this.searchText = this.searchText1;
                    this.searchText1 = '';
                    this.searchText2 = ''
                }
            }
        },
    }
</script>

<style scoped>
    input {
        padding-left: 5px;
        border: black 1px solid;
        border-radius: 3px;
    }

    .half_width_100_plus_toggle {
        width: 35%;
    }

    p {
        font-size: 2em;
        text-align: center;
    }
</style>
