// eslint-disable-next-line import/no-named-as-default
import VuexPersistence from 'vuex-persist'

export default ({ store }: any) => {
  new VuexPersistence({
    storage: window.localStorage
  }).plugin(store)
}