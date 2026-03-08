<script setup>

import { ref } from 'vue'
import axios from 'axios'
import { useAuthStore } from '@/stores/auth-store'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()
const error = ref(null)
const loading = ref(false)
const form = ref({
    name: '',
    username: '',
    password: ''
})

async function register() {
    loading.value = true
    try {
        const result = await axios.post(process.env.VUE_APP_BACKEND_URL + '/register', form.value)
        console.log(result)
        if(result.status == 200) {
            authStore.authUser = result.data.user
            authStore.token = result.data.token
            router.push('/')
        }
        else {
            console.log(result)
            error.value = result.data
        }
        loading.value = false
    }
    catch(error) {
        console.log(error)
        error.value = error.response.data.message

        loading.value = false
    }
}

</script>

<template>

    <v-form class="bg-grey pa-6" style="height: 100vh" @submit.prevent="register">
        <v-card class="py-6" width="80%" style="margin: auto;">
            <v-card-title class="text-center text-h4">REGISTER</v-card-title>
            {{ error }}
            <v-card-item>
                <v-text-field class="mt-2" :error-messages="error" label="Name" v-model="form.name" density="comfortable" variant="outlined"></v-text-field>
                <v-text-field class="mt-2" :error-messages="error" label="Username" v-model="form.username" density="comfortable" variant="outlined"></v-text-field>
                <v-text-field label="Password" type="password" density="comfortable" v-model="form.password" variant="outlined"></v-text-field>
            </v-card-item>
            <v-card-actions>
                <v-btn block color="blue" variant="flat" :loading="loading" type="submit">Register</v-btn>
            </v-card-actions>
            <p class="text-center mb-5">Already have an account?  <router-link to="/login">Login</router-link> </p>
        </v-card>
    </v-form>
    
</template>