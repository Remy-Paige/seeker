<template>
    <input
           class="width_100_plus_toggle"
           type="text"
           :placeholder="placeholder"
           v-model="searchText"
    >
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
                searchText: ''
            }
        },
        mounted () {
            var keywords = this.$store.getters.getKeywordsByIndex(this.index)
            var makeString = ''
            console.log(keywords)
            if(this.field === 'Article' || this.field === 'Section Number') {
                for (var word in keywords) {

                    makeString = makeString + keywords[word] + ' '
                }
                this.searchText = makeString
            } else {
                for (var word in keywords) {

                    makeString = makeString + keywords[word]
                }
                this.searchText = makeString
            }

        },
        computed: {
            field: {
                get () {
                    return this.$store.getters.getFieldByIndex(this.index)
                }
            }
        },
        watch: {
            searchText: function () {
                if(this.field === 'Article' || this.field === 'Section Number') {
                    var input = this.searchText
                    input = input.replace(/[^a-zA-Z0-9\s\.]/g,' ');
                    input = input.trim()
                    var keywords = input.split(/\s+/);
                    this.$store.commit('updateKeywordsByIndex', {index: parseInt(this.index, 10), value: keywords})

                } else {
                    this.$store.commit('updateKeywordsByIndex', {index: parseInt(this.index, 10), value: this.searchText})
                }
            },
            // searchText: function (newValue) { if we want them to be able to type the whole thing
            //     this.$emit('does this work')
            // }
        },
    }
</script>

<style scoped>
    input {
        padding-left: 5px;
        border: black 1px solid;
        border-radius: 3px;
    }
    p {
        font-size: 2em;
        text-align: center;
    }
</style>
