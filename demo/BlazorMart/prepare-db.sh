# You can only run this once the following starts showing that the Mongo container is ready
# TODO: Figure out how to get the Mongo instance to store data in the persistent volume so it's not lost when redeploying
kubectl get all

# Initialize replication set
kubectl exec mongod-0 -c mongod-container -- mongo --eval 'rs.initiate({_id: "MainRepSet", version: 1, members: [ {_id: 0, host: "mongod-0.mongodb-service.default.svc.cluster.local:27017"} ]});'

# Check it's OK
kubectl exec mongod-0 -c mongod-container -- mongo --eval 'rs.status()'

# Import data
kubectl cp ./BlazorMart.Server/products.json mongod-0:/import-products.json
kubectl exec mongod-0 -c mongod-container -- mongo --eval 'db.inventory.drop()' blazormart
kubectl exec -it mongod-0 -c mongod-container -- mongoimport --db=blazormart --collection=inventory --jsonArray --file=/import-products.json

# Check we did get some data
kubectl exec mongod-0 -c mongod-container -- mongo --eval 'db.inventory.count()' blazormart

# To connect to the container running the first replica, e.g., to explore data interactively
# kubectl exec -it mongod-0 -c mongod-container -- bash
# mongo
# use blazormart
# db.inventory.find()
