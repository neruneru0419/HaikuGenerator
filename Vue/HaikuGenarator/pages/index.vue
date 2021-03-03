<template>
  <div class="Login">
    <b-container>
        <h1 class="my-3">俳句ジェネレーター</h1>
        <p>このアプリはTwiiterアカウントが必要です。</p>
        <p>下のボタンからアプリ認証をして始めてください。</p>
        <b-button href="localhost:8888/oauth" variant="primary">ツイート認証</b-button>
   
        <b-form-group label="アカウント名" description="TwitterIDを入力してください">
          <b-form-input v-model="user_name" placeholder=""></b-form-input>
        </b-form-group>
        <b-button class="my-3" variant="primary" @click="generateHaiku()">俳句生成</b-button>

    </b-container> 
  </div>
</template>

<script>
export default {
  data(){
    return{
      haiku: String,
      username: String
    }
  },
  name: "Login",
  methods:{
    gethaiku(){
        this.axios.get("http://localhost:4567/gethaiku")
        .then((response) =>{
          console.log(response.data)
          this.username = response.data
        })
        .catch((e) => {
          console.log(e)
        });
    },
  }
}
</script>

