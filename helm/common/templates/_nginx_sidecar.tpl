{{- define "common.sidecar.container" -}}
        - name: sidecar-nginx
          image: "quay.io/cdis/nginx:master"
          imagePullPolicy: Always
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          volumeMounts:
            - name: "nginx-config"
              mountPath: "/etc/nginx/conf.d/default.conf"
              subPath: default.conf
          readinessProbe:
            httpGet:
              path: /_status
              port: http
          livenessProbe:
            httpGet:
              path: /_status
              port: http
{{- end }}