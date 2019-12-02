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
            field: {
                type: String,
                required: true
            },
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
        watch: {
            searchText: function () {
                if(this.field == 'Article' || this.field == 'Section Number') {
                    if(this.searchText.indexOf(',') > -1) {
                        var keywords = this.searchText.split(',')
                        keywords.map(str => str.replace(/\s/g, ''))
                        this.$emit('updateQueryLine', [this.emitType, this.index, keywords])
                    }
                } else {
                    this.$emit('updateQueryLine', [this.emitType, this.index, this.searchText])
                }
            },
            // searchText: function (newValue) { if we want them to be able to type the whole thing
            //     this.$emit('does this work')
            // }
        },
    }
</script>

<style scoped>
    p {
        font-size: 2em;
        text-align: center;
    }
    .width_100_plus_toggle {
        width: 95%;
    }
</style>
