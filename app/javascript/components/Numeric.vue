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
            filter: {
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
        watch: {
            searchText: function () {
                if(this.filter == 'between'){
                    this.$emit('updateQueryLine', [this.emitType, this.index, [this.searchText1, this.searchText2]])
                } else {
                    this.$emit('updateQueryLine', [this.emitType, this.index, this.searchText])
                }

            },
            filter: function() {
                if(this.filter == 'between'){
                    this.searchText1 = this.searchText;
                    this.searchText = '';
                } else {
                    this.searchText = this.searchText1;
                    this.searchText1 = '';
                    this.searchText2 = ''
                }
            }
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
    .width_100_plus_toggle {
        width: 90%;
    }

    .half_width_100_plus_toggle {
        width: 44.5%;
    }

    p {
        font-size: 2em;
        text-align: center;
    }
</style>
