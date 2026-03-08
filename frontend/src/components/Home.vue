<script setup>

import axios from 'axios'
import { ref, onMounted, watch } from 'vue'
import { useAuthStore } from '@/stores/auth-store'
import { useRouter } from 'vue-router'
import { io } from "socket.io-client"
import { formatDistance } from 'date-fns'

const router = useRouter()
const authStore = useAuthStore()
const snackbar = ref(false)
const snackbarMessage = ref('')
const messages = ref([])
const message = ref('')
const virtualScoller = ref(null)
const activeUsers = ref(0)
const tracks = ref([])
const q = ref('illit')
const currentSong = ref('3A2yGHWIzmGEIolwonU69h')
const play = ref(false)
const itemsPerPage = ref(5)
const dialog = ref(false)
const chosenMessage = ref(null)

const socket = io(process.env.VUE_APP_BACKEND_URL);

socket.on("active users", (users) => {
	activeUsers.value = users
});

socket.on('chat message', () => {
	getAllMessages()
})

socket.on('delete message', () => {
	getAllMessages()
})

watch(itemsPerPage, () => {
	getTracks()
})

onMounted(async () => {
	getAllMessages()

	axios.post('https://accounts.spotify.com/api/token', 
		`grant_type=client_credentials&client_id=${process.env.VUE_APP_CLIENT_ID}&client_secret=${process.env.VUE_APP_CLIENT_SECRET}&scope=user-top-read`, 
		{
			headers: {
				'Content-Type': 'application/x-www-form-urlencoded'
			}
		}
	)
	.then(response => {
		console.log(response.data)
		authStore.access_token = response.data.access_token
		getTracks()
	})
	.catch(error => {
		console.error('Error:', error.response.data);
	});

})

const getAllMessages = () => {
	axios.get(process.env.VUE_APP_BACKEND_URL, {
		headers: {
			Authorization: `Bearer ${authStore.token}`
		}
	})
	.then((res) => {
		messages.value = res.data
		// virtualScoller.value.scrollToIndex(messages.value.length - 1)
	}).catch((err) => {
		console.error(err)
	})
}

const logout = () => {
	
	router.push('/login')
	authStore.logout()
}

const sendMessage = () => {
	axios.post(process.env.VUE_APP_BACKEND_URL + '/send-message', {
		user_id: authStore.authUser.id,
		type: 0,
		message: message.value
	}, {
		headers: {
			Authorization: `Bearer ${authStore.token}`
		}
	}).then((res) => {
		console.log(res)
		if(res.status == 201) {
			socket.emit('chat message')
			message.value = ''
		}
	}).catch((err) => {
		console.error(err)
	})
}

const playSong = (trackId) => {
	currentSong.value = trackId
	play.value = true
}

const shareSong = (trackId) => {
	axios.post(process.env.VUE_APP_BACKEND_URL + '/send-message', {
		user_id: authStore.authUser.id,
		type: 1,
		message: trackId
	}, {
		headers: {
			Authorization: `Bearer ${authStore.token}`
		}
	}).then((res) => {
		console.log(res)
		if(res.status == 201) {
			socket.emit('chat message')
			message.value = ''
			snackbarMessage.value = 'You shared a song'
			snackbar.value = true
		}
	}).catch((err) => {
		console.error(err)
	})
}

const getTracks = () => {
	axios.get(`https://api.spotify.com/v1/search?q=${q.value}&type=track&limit=${itemsPerPage.value}`, {
		headers: {
			Authorization: `Bearer ${authStore.access_token}`
		}
	})
	.then((res) => {
		tracks.value = res.data.tracks.items
		console.log(res)
		// q.value = ''
	})
	.catch((err) => {
		console.log(err)
	})

}

const showDialog = (messageId) => {
	dialog.value = true
	chosenMessage.value = messageId
}

const deleteMessage = () => {
	axios.delete(`${process.env.VUE_APP_BACKEND_URL}/delete-message/${chosenMessage.value}`, {
		headers: {
			Authorization: `Bearer ${authStore.token}`
		}
	})
	.then((res) => {
		console.log(res)
		dialog.value = false
		snackbarMessage.value = 'You deleted a message'
		socket.emit('delete message')
	})
	.catch((err) => {
		console.error(err)
	})
}

</script>

<template>
	<v-container fluid>
		<v-row>
			<v-col cols="12" md="8" lg="8" sm="12">
				<v-form @submit.prevent="getTracks">
					<v-text-field label="Type a song name..." v-model="q">
						<template v-slot:append-inner>
							<v-btn flat type="submit" icon="mdi-magnify" @click="getTracks"></v-btn>
						</template>
					</v-text-field>
				</v-form>
				<v-table title="Songs" hover class="border">
					<thead>
						<tr>
							<th colspan="1" class="font-weight-bold text-h6">Songs</th>
							<th colspan="3">
								<v-select 
									label="Items per page" 
									style="width: 180px" 
									v-model="itemsPerPage" 
									:items="[5, 10, 15, 20]"
									class="mt-2"
								>
								</v-select>
							</th>
						</tr>
						<tr>
							<th class="text-center">
								#
							</th>
							<th class="text-left">
								Title
							</th>
							<th class="text-center">
								Album
							</th>
							<th class="text-center">
								Actions
							</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="(track, index) in tracks" :key="index" class="text-center">
							<td>{{ index + 1 }}</td>
							<td class="text-left">
								<v-list-item :title="track.name">
									<template v-slot:subtitle>
										<p>
											<span v-for="artist in track.artists" :key="artist.id">
												<a :href="artist.external_urls.spotify" target="_blank" rel="noopener noreferrer">
													{{ artist.name }},
												</a>
											</span>
										</p>
									</template>
									<template v-slot:prepend>
										<v-avatar rounded="0">
											<v-img cover :src="track.album.images[0].url"></v-img>
										</v-avatar>
									</template>
								</v-list-item>
							</td>
							<td>
								<a :href="track.album.external_urls.spotify" target="_blank" rel="noopener noreferrer">
									{{ track.album.name }}
								</a>
							</td>
							<td style="display: flex; align-items: center;">
								{{ `${Math.floor(Math.floor(track.duration_ms / 1000) / 60)}:${Math.floor(track.duration_ms / 1000) % 60}` }}
								<v-btn 
									flat 
									density="compact" 
									icon="mdi-play" 
									@click="playSong(track.id)"
								>
								</v-btn>
								<v-btn 
									flat 
									density="compact" 
									icon="mdi-share" 
									@click="shareSong(track.id)"
								>
								</v-btn>
							</td>
						</tr>
					</tbody>
				</v-table>
                <iframe class="mt-4" id="spotifyIframe" style="border-radius:12px" :src="`https://open.spotify.com/embed/track/${currentSong}?utm_source=generator&autoplay=1`" width="100%" height="152" frameBorder="0" allowfullscreen="" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>
			</v-col>
			<v-col cols="12" md="4" lg="4" sm="12" xs="12" class="border">
				<!-- <div>
					<span class="font-weight-bold text-h6"> Chats </span> 
					<v-badge color="error" content="2">
						<v-icon>mdi-play</v-icon>
					</v-badge>
				</div> -->
				<v-list-item>
					<div class="pa-3">
					<span class="font-weight-bold text-h6"> Chats </span> 
					<v-badge color="error" :content="activeUsers">
						<v-icon>mdi-account-multiple</v-icon>
					</v-badge>
				</div>
					<template v-slot:append>
						<v-menu>
							<template v-slot:activator="{ props }">
								<v-btn v-bind="props" flat class="text-none">
									<template v-slot:prepend>
										<v-avatar class="me-3">
											<v-img cover src="https://upload.wikimedia.org/wikipedia/en/a/a0/Blonde_-_Frank_Ocean.jpeg"></v-img>
										</v-avatar>	
									</template>
									{{ authStore.authUser?.name }}
									<v-icon class="ms-2">mdi-chevron-down</v-icon>
								</v-btn>
							</template>
							<v-list>
								<v-list-item @click="logout" class="text-red" prepend-icon="mdi-logout">
									<v-list-item-title>Logout</v-list-item-title>
								</v-list-item>
							</v-list>
						</v-menu>
					</template>
				</v-list-item>
				<v-virtual-scroll :height="450" :items="messages" ref="virtualScoller">
					<template v-slot:default="{ item }">
						<div v-if="item.type" class="text-center">
							<div v-if="item.deleted_at">
								<v-row :justify="item.user_id == authStore.authUser?.id ? 'end' : ''" class="mx-2 my-1">
									<v-col cols="auto" class="border" style="border-radius: 30px;">
										<p class="mx-3 text-light py-1">
											<i>{{ item.name }} unsint a message.</i>
											<br>
											<span class="font-weight-light" style="font-size: 15px;">
												{{ formatDistance(new Date(), item.created_at) }}
											</span>
										</p>
									</v-col>
								</v-row>
							</div>
							<div v-else>
								<div v-if="item.user_id == authStore.authUser?.id">
									{{ item.name }}
									<v-menu>
										<template v-slot:activator="{ props }">
											<v-btn icon="mdi-dots-horizontal" color="blue" v-bind="props" size="xs"></v-btn>
										</template>

										<v-list>
											<!-- <v-list-item title="Edit"></v-list-item> -->
											<v-list-item title="Unsend" @click="showDialog(item.id)"></v-list-item>
										</v-list>
									</v-menu>
								</div>
								<iframe class="" style="border-radius:12px" :src="`https://open.spotify.com/embed/track/${item.message}?utm_source=generator`" width="100%" height="152" frameBorder="0" allowfullscreen="" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>
							</div>
						</div>
						<div v-else>
							<div v-if="item.user_id !== authStore.authUser?.id">
								<span class="ms-7">{{ item.name }}</span>
								<v-row class="mx-2 my-1">
									<v-col cols="auto" class="bg-grey" style="border-radius: 30px;" v-if="!item.deleted_at">
										<p class="mx-3 text-light py-1">
											{{ item.message }}
											<br>
											<span class="font-weight-light" style="font-size: 15px;">
												{{ formatDistance(new Date(), item.created_at) }}
											</span>
										</p>
									</v-col>
									<v-col cols="auto" class="border" style="border-radius: 30px;" v-else>
										<p class="mx-3 text-light py-1">
											<i>{{ item.name }} unsint a message.</i>
											<br>
											<span class="font-weight-light" style="font-size: 15px;">
												{{ formatDistance(new Date(), item.created_at) }}
											</span>
										</p>
									</v-col>
								</v-row>
								
							</div>
							<v-row class="mx-2 my-1" justify="end" v-else style="position: relative;">
								<v-col cols="auto" class="bg-secondary" style="border-radius: 30px;" v-if="!item.deleted_at">
									<div style="position: absolute; top: -12px; right: 0; z-index: 1;">
										<v-menu>
											<template v-slot:activator="{ props }">
												<v-btn icon="mdi-dots-horizontal" color="blue" v-bind="props" size="xs"></v-btn>
											</template>

											<v-list>
												<!-- <v-list-item title="Edit"></v-list-item> -->
												<v-list-item title="Unsend" @click="showDialog(item.id)"></v-list-item>
											</v-list>
										</v-menu>
									</div>
									<p class="mx-3 text-light py-1">
										{{ item.message }}
										<br>
										<span class="font-weight-light" style="font-size: 15px;">
											{{ formatDistance(new Date(), item.created_at) }}
										</span>
									</p>
								</v-col>
								<v-col cols="auto" class="border" style="border-radius: 30px;" v-else>
									<p class="mx-3 text-light py-1">
										<i>You unsint a message.</i>
										<br>
										<span class="font-weight-light" style="font-size: 15px;">
											{{ formatDistance(new Date(), item.created_at) }}
										</span>
									</p>
								</v-col>
							</v-row>
						</div>
					</template>
				</v-virtual-scroll>
				<v-form @submit.prevent="sendMessage">
					<v-text-field label="Abc" class="mt-4" v-model="message">
						<template v-slot:append-inner>
							<v-btn icon="mdi-send" type="submit" @click="sendMessage" flat></v-btn>
						</template>
					</v-text-field>
				</v-form>
			</v-col>
		</v-row>
		<v-snackbar v-model="snackbar" location="top">
			{{ snackbarMessage }}
		</v-snackbar>
		<v-dialog v-model="dialog">
			<v-card title="Unsend message">
				<v-card-text>
					Are you sure you want to unsend this message?
				</v-card-text>
				<v-card-actions justify="end">
					<v-btn @click="dialog = false">Cancel</v-btn>
					<v-btn color="red" @click="deleteMessage">Unsend</v-btn>
				</v-card-actions>
			</v-card>
		</v-dialog>
	</v-container>
</template>

<style scoped>

	a {
		text-decoration: none;
		color: black
	}

	a:hover {
		text-decoration: underline;

	}

</style>